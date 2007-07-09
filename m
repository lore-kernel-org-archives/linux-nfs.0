From: David Liontooth <liontooth@cogweb.net>
Subject: Re: NFS using iptables PREROUTING?
Date: Mon, 09 Jul 2007 11:37:53 -0700
Message-ID: <46928081.4040209@cogweb.net>
References: <46910E50.2020000@cogweb.net>	<4691D4BC.2010007@cogweb.net>
	<20070709063902.675c49e3.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I7y7U-0008A6-3c
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 11:38:00 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I7y7X-0005IQ-JY
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 11:38:03 -0700
In-Reply-To: <20070709063902.675c49e3.jlayton@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Jeff Layton wrote:
> On Sun, 08 Jul 2007 23:25:00 -0700
> David Liontooth <liontooth@cogweb.net> wrote:
>
>   
>> David Liontooth wrote:
>>     
>>> Is it possible to access an NFS server on a private network from a 
>>> machine on a public network?
>>>   
>>>       
>> It turns out to be a lot simpler than I thought -- no need to worry 
>> about lockd, portmap, or statd.
>>
>> On the host A, set the mountd port in /etc/default/nfs-kernel-server:
>>
>>     RPCMOUNTDOPTS="--port 4000"
>>
>> In the gateway G's /etc/network/if-up.d/00-firewall, forward the NFS and 
>> the mountd ports
>>
>>     # NFS: Forward udp on port 2049 to A on the private network
>>     iptables -t nat -A PREROUTING -p udp -d 128.65.183.178 --dport 9101 
>> -j DNAT --to 192.168.0.3:2049
>>
>>     # Forward tcp and udp for mountd on A (port assigned in 
>> A:/etc/default/nfs-common)
>>     iptables -t nat -A PREROUTING -p tcp -d 128.65.183.178 --dport 9201 
>> -j DNAT --to 192.168.0.3:4000
>>     iptables -t nat -A PREROUTING -p udp -d 128.65.183.178 --dport 9201 
>> -j DNAT --to 192.168.0.3:4000
>>
>> In the client B's /etc/hosts, define an alias for the NFS host behind 
>> the firewall, using the IP address of the gateway:
>>
>>    128.65.183.178  a.fully.qualified.domain.name   A
>>
>> And in the client B's /etc/fstab, define the mount, adding the gateway's 
>> ports that forward NFS and mountd to the host:
>>
>>    A:/db1 /mnt/a1 nfs 
>> noauto,user,exec,rw,rsize=16k,wsize=16k,hard,intr,port=9101,mountport=9201 
>> 0 0
>>
>> Works beautifully and transparently. Or does someone spot a potential 
>> problem?
>>
>>     
>
> That should work fine, unless you have applications that do posix locking.
> In that case, you'll likely have problems since lockd can't be reached. An
> even easier method might be to consider moving to NFSv4, which just uses
> port 2049 for everything.
>
>   
Very useful, thank you.



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
