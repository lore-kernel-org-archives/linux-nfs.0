From: Santiago <santi@mleads.com>
Subject: Re: RedHat/Mandrake NFS - not playing nice
Date: Mon, 17 Feb 2003 15:04:30 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E515C6E.6040609@mleads.com>
References: <3E5110B0.6000002@mleads.com> <shswujywwe6.fsf@charged.uio.no>
Reply-To: santi@mleads.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [64.92.112.32] (helo=mail.hosting-advantage.com)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ktN4-0003nX-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 14:04:18 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Thanks for responding so quickly Trond. I'm replying inline.

Trond Myklebust wrote:
>>>>>>" " == santi  <Santiago> writes:
>>>>>
> 
>      > The Mandrake 9.0 is stock distro with kernel 2.4.19-ac4
>      > (custom) with NFS support compiled in.
> 
> You appear to have forgotten to compile NFSv3 into this kernel. Try to
> specify the option '-onfsvers=2'.

I recompiled the kernel to support all versions of NFS:
 
lqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk 
x
x x             < > Coda file system support (advanced network fs) 
                          x x             < > InterMezzo file system 
support (experimental,
x x             <*> NFS file system support 
                          x x             [*]   Provide NFSv3 client 
support                                               x x 
<*> NFS server support 
          x x             [*]   Provide NFSv3 server support 
                                    x x             [*]   Provide NFS 
server over TCP support (EXPERIMENTAL)                         x x 
        <*> SMB file system support (to mount Windows shares 
               x x             [*]   Use a default NLS 
                                           x x 
Default Remote NLS Option: "cp437" 
   x x             < > NCP file system support (to mount NetWare 
volumes)                           x x
mqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj 
x 
tqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqu
x                                 <Select>    < Exit >    < Help > 
                            x 
mqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj


> You appear also not to be running rpc.statd on that machine. Unless
> you also use the 'nolock' mount option, you will end up with problems
> the first time some process tries to lock a file.

I took care of this too. Thanks for pointing it out.

[root@backup linux]# rpcinfo -p
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100011    1   udp    682  rquotad
     100011    2   udp    682  rquotad
     100011    1   tcp    685  rquotad
     100011    2   tcp    685  rquotad
     100003    2   udp   2049  nfs
     100003    3   udp   2049  nfs
     100003    2   tcp   2049  nfs
     100003    3   tcp   2049  nfs
     100021    1   udp  32770  nlockmgr
     100021    3   udp  32770  nlockmgr
     100021    4   udp  32770  nlockmgr
     100021    1   tcp  32796  nlockmgr
     100021    3   tcp  32796  nlockmgr
     100021    4   tcp  32796  nlockmgr
     100005    1   udp  32771  mountd
     100005    1   tcp  32797  mountd
     100005    2   udp  32771  mountd
     100005    2   tcp  32797  mountd
     100005    3   udp  32771  mountd
     100005    3   tcp  32797  mountd
     100024    1   udp  32772  status
     100024    1   tcp  32798  status


However, I still am receiving the same error as before:
[root@backup linux]# mount 10.0.0.48:/var/www/html /r/amanda/nitro-html 
-t nfs
mount: 10.0.0.48:/var/www/html failed, reason given by server: 
Permission denied
[root@backup linux]#

Any more ideas or suggestions?

Thanks,

Santiago



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
