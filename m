From: jehan procaccia <jehan.procaccia@int-evry.fr>
Subject: Re: async vs. sync
Date: Mon, 22 Nov 2004 22:25:35 +0100
Message-ID: <41A2594F.5000909@int-evry.fr>
References: <482A3FA0050D21419C269D13989C61130435EBD2@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net, mci-unix@int-evry.fr
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWLhB-0000Yi-Dr
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 13:26:01 -0800
Received: from smtp2.int-evry.fr ([157.159.10.45])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CWLh6-0001m9-FH
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 13:26:01 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435EBD2@lavender-fe.eng.netapp.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Lever, Charles wrote:

>>in my old solaris 7 nfs it was async I suppose ! although we 
>>didn't lose data, maybe we where risking it ... ?
>>    
>>
>
>the Solaris NFS server doesn't support an "async" mode.
>  
>
bad news for me !

>  
>
>>anyway now I move from and old 
>>solaris NFS server to a brand new linux one with a SAN 
>>(AX100) Storage 
>>Processor in Raid 5 an Fiber Channel attachement, how can I support 
>>performances more than 50 times longer :-( with that config,  
>>user and 
>>manager wil tell me that I  spoild money on that new server !, there 
>>must be a misconfiguration somewhere ?.
>>    
>>
>
>take a walk through the NFS how-to http://nfs.sourceforge.net/howto/ to
>see if there is anything useful there.
>  
>
I did that already, but maybe I should go through again ...

>also, you could measure your file system performance locally on the NFS
>server instead of via an NFS client to see if your RAID and local file
>system is configured correctly.
>  
>
No problem, it goes very fast ! 4s for 13 minutes in NFS async mode :-(
[root@cobra3 /p2v5f1/mci/test/Test-sync]
$ time tar xvfz /tmp/httpd-2.0.51.tar.gz
real    0m4.404s
user    0m0.450s
sys     0m0.770s

>finally, you should look at raw network performance between your clients
>and server to make sure you are not losing any performance there.
>  
>
No, anyway in async mode it's OK, but proof is here with iperf in udp 
mode -> 93.7 Mbits/s on a 100 Mbits/sec ethernet network !
[root@arvouin Test-sync]# iperf -c cobra3 -i 1 -u -b 100000000

[root@cobra3 ~]
$ iperf -s -i 1 -u
[  3]  0.0-10.0 sec   112 MBytes  93.7 Mbits/sec  0.053 ms    0/79767 (0%)

I've also tried to stop iptables firewall on both side (client/server) 
no way :-( .
Anyone is getting the same performance as me in server sync mode ?, if 
someone could just tar xvfz any recent httpd.tar.gz file (nearly 3000 
source files) and let me know how it take on their nfs configuration ?

Thanks.





-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
