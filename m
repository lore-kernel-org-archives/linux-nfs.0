From: Daniel Brunner <daniel.brunner@dunidester.com>
Subject: Re: NFS over TCP on a Linux server
Date: Wed, 22 May 2002 13:07:39 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <CDC961E9-6DAE-11D6-A96E-00306589E6DA@dunidester.com>
References: <1022086125.3cebcbed126f3@webmail.mechanus.org>
Mime-Version: 1.0 (Apple Message framework v481)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: segleaur@mechanus.org
In-Reply-To: <1022086125.3cebcbed126f3@webmail.mechanus.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hello!!

Actually, the NFS How-To doesn't really explain how to do it...


My NFS server runs UDP...and we like it...it's on a LinuxPPC box, and 
services the Mac department...it's pretty quick with files over 500 
MB...using UDP..



Dan





On Wednesday, May 22, 2002, at 11:48 AM, segleaur@mechanus.org wrote:

>
> You might want to read the How-To at the NFS site. It's pretty complete 
> and not
> hard to follow. (http://nfs.sourceforge.net/nfs-howto/)
>
> Personally, I just made sure that the portmapper was running when I 
> configured
> NFS, and that all the daemons were running. One the client side, I ust 
> placed
> the mount points in the etc/fstab and voila, it runs like a charm. well,
> almost. the overhead is amazing, but not notice-able from the outside 
> world.
>
> Cheers,
>
>
> Rodolfo
>
>
> Quoting Vladimir Vuksan <croatia@firstlinux.net>:
>
>> I am trying to set up NFS over TCP on a Linux server. However I cannot 
>> figure
>> out how to register NFS over TCP with the portmapper ie. Doing 
>> pmap_dump
>> yields
>>
>>     100003    2   udp   2049  nfs
>>     100003    3   udp   2049  nfs
>>
>> I tried adding
>>
>>     100003    3   tcp   2049  nfs
>>
>> and doing
>>
>> cat p.dump | pmap_set
>>
>> but that doesn't seem to work.
>>
>> How does one register it ?
>>
>> Thanks,
>> Vladimir
>>
>> _____________________________________________________________
>> Want a new web-based email account ? ---> http://www.firstlinux.net
>>
>> _____________________________________________________________
>> Promote your group and strengthen ties to your members with
>> email@yourgroup.org by Everyone.net  http://www.everyone.net/?btn=tag
>>
>> _______________________________________________________________
>>
>> Don't miss the 2002 Sprint PCS Application Developer's Conference
>> August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm
>>
>> _______________________________________________
>> NFS maillist  -  NFS@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/nfs
>>
>
> _______________________________________________________________
>
> Don't miss the 2002 Sprint PCS Application Developer's Conference
> August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm
>
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
