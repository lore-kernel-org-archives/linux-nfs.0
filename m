From: "Gregory Baker" <gregory.baker@amd.com>
Subject: Re: inconsistent mount attributes (ro/rw), RHEL5 / Netapp
Date: Thu, 19 Apr 2007 13:24:29 -0500
Message-ID: <4627B3DD.5050409@amd.com>
References: <46269362.5040608@amd.com>
	<1176948355.6422.72.camel@heimdal.trondhjem.org>
Reply-To: gregory.baker@amd.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: julia bauer <julia.bauer@amd.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HebJI-0000yZ-E4
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 11:24:48 -0700
Received: from outbound-sin.frontbridge.com ([207.46.51.80]
	helo=outbound3-sin-R.bigfish.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HebJJ-0003oX-UO
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 11:24:51 -0700
In-Reply-To: <1176948355.6422.72.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net



It becomes more interesting (well, to me anyways) when you compare the 
behavior of RHEL3/4 (ro,rw netgroup export from filer works) with RHEL 5 
(ro,rw netgroup export from filer no works).

---+ System environment

[root@build-el3-64 greg]# uname -a
Linux build-el3-64 2.4.21-47.ELsmp #1 SMP Wed Jul 5 20:30:30 EDT 2006 
x86_64 unknown unknown GNU/Linux

[root@build-el3-64 greg]# rpm -qa | grep nfs-utils
nfs-utils-1.0.6-44EL

[root@build-el3-64 mnt2]#  mount -V
mount: mount-2.11y

---+ NFS server (Netapp) environment

[greg@apathy greg]$ sudo rsh eng version
NetApp Release 7.2P4: Tue Nov 28 02:55:54 PST 2006

---++ NFS export file entry

[greg@apathy greg]$ sudo rsh eng exportfs | grep pandora
/vol/vol4/pandora
  -sec=sys,ro,rw=@volexport-pandora,root=@volexport-pandora,anon=4058

---++ netgroup member (for export file entry above)

[root@build-el3-64 mnt2]# show_netgroup volexport-pandora | grep 
build-el3-64

build-el3-64.amd.com

---+ Demonstration of ro/rw mount reporting and working

[root@build-el3-64 greg]# mount 
eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2

[root@build-el3-64 greg]# mount -v | grep mnt2
eng:/vol/vol4/pandora/pandora-k26_g25_64-2 on /mnt2 type nfs 
(rw,addr=163.181.34
.137)

[root@build-el3-64 greg]# cat /proc/mounts | grep mnt2
eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2 nfs 
rw,v3,rsize=32768,wsize=327
68,hard,udp,lock,addr=eng 0 0

[root@build-el3-64 greg]# cd /mnt2

[root@build-el3-64 mnt2]# touch asdf

[root@build-el3-64 mnt2]# ls -la asdf
-rw-r--r--    1 root     root            0 Apr 19 13:18 asdf

Ideas?

Thanks,

--Greg

Trond Myklebust wrote:
> On Wed, 2007-04-18 at 16:53 -0500, Gregory Baker wrote:
>> Note I have cases open with Redhat and Netapp, but was curious if other 
>> people have also seen inconsistent mount attributes (ro/rw) when 
>> mounting RHEL5 client vs. Netapp 7.2 Ontap.
>>
>> ---+ System environment
>>
>> [greg@adcgar04 greg]$ uname -a
>> Linux adcgar04 2.6.18-8.el5 #1 SMP Fri Jan 26 14:15:14 EST 2007 x86_64 
>> unknown unknown GNU/Linux
>>
>> [greg@adcgar04 greg]$ rpm -qa | grep nfs-utils
>> nfs-utils-1.0.9-16.el5
>> nfs-utils-lib-1.0.8-7.2
>> nfs-utils-lib-devel-1.0.8-7.2
>> nfs-utils-lib-1.0.8-7.2
>> nfs-utils-lib-devel-1.0.8-7.2
>>
>> [greg@adcgar04 greg]$ mount -V
>> mount (util-linux 2.13-pre7)
>>
>> ---+ NFS server (Netapp) environment
>>
>> [greg@apathy greg]$ sudo rsh eng version
>> NetApp Release 7.2P4: Tue Nov 28 02:55:54 PST 2006
>>
>> ---++ NFS export file entry
>>
>> [greg@apathy greg]$ sudo rsh eng exportfs | grep pandora
>>
>> /vol/vol4/pandora 
>> -sec=sys,ro,rw=@volexport-pandora,root=@volexport-pandora,anon=4058
>>
>> ---++ netgroup member (for export file entry above)
>>
>> [greg@apathy greg]$ show_netgroup volexport-pandora | grep adcgar
>> adcgar04.amd.com
>>
>> ---+ Demonstration of inconsistent ro/rw mount reporting
>>
>> [root@adcgar04 /]# mount eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2
>>
>> [root@adcgar04 /]# mount -v | grep mnt2
>> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 on /mnt2 type nfs 
>> (rw,addr=163.181.34.137)
>>
>> [root@adcgar04 /]# cat /proc/mounts | grep mnt2
>> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2 nfs 
>> ro,vers=3,rsize=65536,wsize=65536,hard,intr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
>> 0 0
>>
>> [root@adcgar04 /]# cd /mnt2/
>>
>> [root@adcgar04 mnt2]# touch asdf
>> touch: cannot touch `asdf': Read-only file system
>>
>> ---+ Discussion
>>
>> ---++Linux (RHEL3/4) NFS servers that have similiar exportfs options
>>
>> /tmp    *(ro,anonuid=4058) @volexport-pandora(rw,no_root_squash)
>>
>> do not cause the inconsistent behavior between mount -v and /proc/mounts 
>> (and it is mounted rw as expected on the client).
>>
>> ---++ A reply from NetApp had this info:
>>
>> Starting with ONTAP 7.2.1 onward, ONTAP will display the "most
>> pessimistic" permissions to NFSv3 and NFSv4 clients. NFSv2 clients will
>> see permissions the same way as in previous releases of ONTAP, i.e. the
>> "most optimistic" permissions.
>>
>> And mounting using NFS v2 (instead of v3) does give us the expected 
>> rw/rw consistency and ability.
>>
>> ---++ So now what?
>>
>> Should the linux mount -v and cat /proc/mounts be consistent with what 
>> is actually happening?
> 
> There is no way for the Linux client to find out that this is a
> read-only volume at mount time. Only when you try an operation that
> actually attempts to modify the filesystem will the protocol allow the
> server to return NFSERR_ROFS.
> Furthermore, there is nothing in the protocol that states that a
> filesystem that issues NFSERR_ROFS will return the same reply the next
> time the same modification is attempted. Filesystems may switch from
> being read only to not being read only at will.
> 
>> Should netapp exports syntax handle a wildcard ro and a netgroup rw?
> 
> That is a very good question, but it deserves to be directed to the
> appropriate people at netapp and is not really appropriate for
> nfs@lists.sourceforge.net (which is more about Linux NFS). If you
> haven't already done so, I'd suggest opening an official escalation of
> the matter. Your embedded netapp sales representative (sorry, but I'm
> not entirely up to date on who that is) should be able to help you with
> this.
> 
> Cheers
>   Trond
> 

-- 
----------------------------------------------------------------------
Greg Baker                                         512-602-3287 (work)
gregory.baker@amd.com                              512-602-6970 (fax)
5204 E. Ben White Blvd MS 625                      512-555-1212 (info)
Austin, TX 78741




-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
