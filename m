From: Brian Tinsley <btinsley@emageon.com>
Subject: Re: What is this Error mean
Date: Mon, 15 Jul 2002 14:55:09 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D33289D.6080506@emageon.com>
References: <20020715184605.70396.qmail@web14003.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from blount.mail.mindspring.net ([207.69.200.226])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17UBwR-000121-00
	for <nfs@lists.sourceforge.net>; Mon, 15 Jul 2002 12:55:31 -0700
To: Sambit Nanda <sambitnanda@yahoo.com>
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

I believe in your exports file on the Linux system, the options for the 
AIX system need to include the "insecure" option. Also, just to be 
clean, you should export and mount the CDROM directory read-only.


Sambit Nanda wrote:

>Hi
>  I have configure my Linux box as a NFS Server and
>trying to mount the server CDROM on AIX 4.33 Machine 
>
>My server 'Linux Machine'  Configuration is  like this
>
>
>/etc/hosts.allow
>portmap:ALL
>rquotad:ALL
>portmap:rtst1a01.sbc.com , intercon1.snet.com
>portmap:132.201.1.136
>lockd:132.201.1.136
>mountd:132.201.1.136
>statd:132.201.1.136
>lockd:rtst1a01.sbc.com , intercon1.snet.com
>mountd:rtst1a01.sbc.com , intercon1.snet.com
>statd:rtst1a01.sbc.com , intercon1.snet.com
>--------------------------------------------
>[root@reportsrv init.d]#  more /etc/exportfs
>/etc/exportfs: No such file or directory
>[root@reportsrv init.d]# more /etc/exports
>/mnt/cdrom rtst1a01.sbc.com(ro) \
>           cid63.sbc.com(rw,no_root_squash) \
>           intercon1.snet.com(rw,no_root_squash)
>
>/home      rtst1a01.sbc.com(rw,no_root_squash) \
>           cid63.sbc.com(rw,no_root_squash) \
>           intercon1.snet.com(rw,no_root_squash)
>
>-----------------------------------------------
>my exportfs -rav comamnd gives output like
>
>[root@reportsrv init.d]# exportfs -rav
>exporting intercon1.snet.com:/mnt/cdrom
>exporting cid63.sbc.com:/mnt/cdrom
>exporting rtst1a01.sbc.com:/mnt/cdrom
>exporting intercon1.snet.com:/home
>exporting cid63.sbc.com:/home
>exporting rtst1a01.sbc.com:/home
>reexporting intercon1.snet.com:/mnt/cdrom to kernel
>reexporting cid63.sbc.com:/mnt/cdrom to kernel
>reexporting rtst1a01.sbc.com:/mnt/cdrom to kernel
>reexporting intercon1.snet.com:/home to kernel
>reexporting cid63.sbc.com:/home to kernel
>reexporting rtst1a01.sbc.com:/home to kernel
>[root@reportsrv init.d]#
>
>
>-------------------------------------------
>
>rpcinfo -p command give results 
>
>like 
>root@reportsrv init.d]# rpcinfo -p
>   program vers proto   port
>    100000    2   tcp    111  portmapper
>    100000    2   udp    111  portmapper
>    100021    1   udp   1024  nlockmgr
>    100021    3   udp   1024  nlockmgr
>    100021    1   tcp   1024  nlockmgr
>    100021    3   tcp   1024  nlockmgr
>    100024    1   udp    939  status
>    100024    1   tcp    941  status
>    100011    1   udp    606  rquotad
>    100011    2   udp    606  rquotad
>    100005    1   udp    614  mountd
>    100005    1   tcp    616  mountd
>    100005    2   udp    619  mountd
>    100005    2   tcp    621  mountd
>    100003    2   udp   2049  nfs
>
>ps -ef | grep nfs results on  linux machine 
>
>[root@reportsrv init.d]# ps -ef | grep nfs
>root       862     1  0 09:42 ?        00:00:00
>rpc.mountd --no-nfs-version 3
>root       871     1  0 09:42 pts/4    00:00:00 [nfsd]
>root       872     1  0 09:42 pts/4    00:00:00 [nfsd]
>root       873     1  0 09:42 pts/4    00:00:00 [nfsd]
>root       874     1  0 09:42 pts/4    00:00:00 [nfsd]
>root       875     1  0 09:42 pts/4    00:00:00 [nfsd]
>root       876     1  0 09:42 pts/4    00:00:00 [nfsd]
>root       877     1  0 09:42 pts/4    00:00:00 [nfsd]
>root       878     1  0 09:42 pts/4    00:00:00 [nfsd]
>root       914   810  0 10:33 pts/4    00:00:00 grep
>nfs
>
>
>I did not find any Error on my boot.log files or
>message files on Linux Box 
>
>
>But while i am trying to mount the /mnt/cdrom of linux
>box  on AIX Box using commands
>
>$ mount -v nfs  151.109.46.15:/mnt/cdrom sambit
>mount: 1831-008 giving up on:
>151.109.46.15:/mnt/cdrom
>vmount: Operation not permitted.
>$ mount 151.109.46.15:/mnt/cdrom sambit
>mount: 1831-008 giving up on:
>151.109.46.15:/mnt/cdrom
>vmount: Operation not permitted. 
>
>I am gettings this Error Operation not permitted
>
>Please note my user ID in the system Group of AIX and
>i am getting this same results while trying to mount
>as a root users also. I also used  no_root_squash in
>/etc/exports but did not get any good results
>
>Can you please give me idea where i got lost. 
>
>Thanks,
>
>Sambit
>
>
>
>=====
>Thanks,
>
>Sambit Nanda
>S.A, Sbc.Com
>203-934-8999/2487 (H)
>203-887-8836 (M)
>203-553-3424 (O)
>
>__________________________________________________
>Do You Yahoo!?
>Yahoo! Autos - Get free new car price quotes
>http://autos.yahoo.com
>
>
>-------------------------------------------------------
>This sf.net email is sponsored by:ThinkGeek
>Welcome to geek heaven.
>http://thinkgeek.com/sf
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
