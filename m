From: "White, NGH (Nick) " <N.G.H.White@rl.ac.uk>
Subject: NFS Client processes lock up
Date: Fri, 4 Jul 2003 18:47:24 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <350DC7048372D31197F200902773DF4C0396448D@exchange11.rl.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "White, NGH (Nick) " <N.G.H.White@rl.ac.uk>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from exchange01.rl.ac.uk ([130.246.135.134])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19YV0R-00005z-00
	for <nfs@lists.sourceforge.net>; Fri, 04 Jul 2003 11:09:59 -0700
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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

Hi,

We are experiencing an issue with NFS client processes locking
up during a transfer. These use the automounter to activate the
connection. The most visual indicator is that the processes have
a "D" status from 'ps -ale' and the WCHAN is lock_page. The processes
cannot be killed.

I've put some more meat on the bones of this below but was wondering
whether this issue is the same as 747194 and whether anyone could
advise on a resolution/bypass. We are running Red Hat 7.3 and the
kernel version is included below. 

The file can be copied locally without any issues on the server that
hosts it. No SCSI errors or array issues occur from file
access. It also checksums fine.

The log for the client shows that there was nothing untoward as far
as that machine during one of the hangs.

The process hangs in state D and hung trying to get a lock
which was almost certainly available. You are unable to strace 
the process using -p pidno. That hangs solid as well. Debug 
mode on rpc doesn't show anything either. 

There is no TCP traffic between client and server after the 
hang, so although the filesystem is available, when the 'dd' 
in my case started the process hung solid. 
'ps' shows the WCHAN as lock_page and the code is included 
below for completeness sake. Basically, what is happening is 
that the process is waiting for data to be retrieved 
off the network, disk, memory, paging or swapping. We can't tell 
exactly where because we cannot trace the process further by 
attaching strace to the pid. We have to run the program under 
strace.

There is nothing reported in the Red Hat bug database. 
Information out on the web infers that it may be an issue caused 
by NFSv3.  NFSv3 could be the issue but unlikely. What is more 
likely is that the change of timing by using NFSv2 could very 
easily be enabling the processes to complete. 
However, using NFSv3 is generally more performant than NFSv2. 
In this case though, this is debatable as the process finishing 
using NFSv2 is always going to be more performant than
a hanging NFSv3 process. 

Mounting the filesystem on it's own mount point on the client and then
doing a 'dd' of the offending file to /dev/null completes without an
issue, even after we have had a hang via the automounter. This 
proves that the server is still making the filesystem available. Whilst I
have 
managed to get 2 'dd' processes to hang when accessing the file through the 
automounter on the client, I have managed to get 2 clean runs when accessing

the file through its own mount point, again on the same client.

The client has the following processes all hung on lock_page:

000 D  5766  9952     1  0  75   0    -   459 lock_p 00:00:00 gtar 
000 D  5766 10839     1  0  75   0    -   459 lock_p 00:00:00 gtar 
000 D  5766  1893     1  0  75   0    -   418 lock_p 00:00:00 cp 
000 D 33004  5483     1  0  75   0    -   420 lock_p 00:00:00 dd 
100 D     0 29679  5939  0  75   0    -   419 lock_p 00:00:00 dd 
plus a few more now

   1893  0.0  0.0  1672  528 cp       lock_page
   5483  0.0  0.0  1680  536 dd       lock_page (and process 29679)

The tcpdump trace on the server shows that no request(read) has been
sent by the client when the hang on the client occurs.

The lock_page code is in mm/filemap.c

/*
 * Get an exclusive lock on the page, optimistically
 * assuming it's not locked..
 */
void lock_page(struct page *page)
{
        if (TryLockPage(page))
                __lock_page(page);
}

TryLockPage is a macro.

static void __lock_page(struct page *page)
{
        struct task_struct *tsk = current;
        DECLARE_WAITQUEUE(wait, tsk);

        add_wait_queue_exclusive(&page->wait, &wait);
        for (;;) {
                sync_page(page);
                set_task_state(tsk, TASK_UNINTERRUPTIBLE);
                if (PageLocked(page)) {
                        run_task_queue(&tq_disk);
                        schedule();
                        continue;
                }
                if (!TryLockPage(page))
                        break;
        }
        tsk->state = TASK_RUNNING;
        remove_wait_queue(&page->wait, &wait);
}

The issue can minifest itself in other ways:

1. The client doesn't even send a request so we never start.
2. The client sends 2 requests to the server, which confuses 
   the heck out of it.

Another tcpdump shows that the client is receiving the 
appropriate reply from the server but it does not send out 
the getattr request to the server for the next block of data. 

The server is definitely responding correctly to the client. 
tcpdump shows the client now needs to send data to the server 
in order to action the read.

strace -f dd if=<file> of=/dev/null
.......
>write(1, 
"\333\307\27\315\\%\10\\c\352\236\310\373\31\33Ge\254\1"..., 512) = 512
read(0, 
"\3141\2001\260\35\31(\234\217G\332\365H|\v,\247\2228\25"..., 512) = 512
write(1, 
"\3141\2001\260\35\31(\234\217G\332\365H|\v,\247\2228\25"..., 512) = 512
read(0, 
"\335\373\213H\0\264\1[\262\f\225\203WnF\r\337\37\"\213"..., 512) = 512
write(1, 
"\335\373\213H\0\264\1[\262\f\225\203WnF\r\337\37\"\213"..., 512) = 512
read(0, 
"&\25\224\36Y\25\n\26Y\330\343+\266\324Qk\363\224\211\370"...,512) = 512
write(1, 
"&\25\224\36Y\25\n\26Y\330\343+\266\324Qk\363\224\211\370"..., 512) = 512
read(0, 
"a)\235\364\272\370\24\230\2>Z;0\26\247\307l\31\350\331"..., 512) = 512
write(1, 
"a)\235\364\272\370\24\230\2>Z;0\26\247\307l\31\350\331"..., 512) = 512
read(0, 

The client is blocked on read i/o. 

This is not a direct server issue.

lock_page is called from a variety of points affecting paging, 
swap, disk and memory io.
The client does not have issues with memory or swap being low. 
Hence, my suspicion is that this is related to disk io or the 
glue between the layers in actioning a read, which is then 
transfered across the network. 
It could be bad memory but unlikely as that usually manifests 
itself as other things such as Ooops or kernel panics, as well,
non of which we are experiencing.

The client is running Red Hat 2.4.18-27.7.xsmp and the automounter
will mount the server with the following attributes:

* -intr,retrans=5,timeo=20,actimeo=0,rw,hard,nosuid,rsize=8192,wsize=8192 
system:/mntpt-&

Thanks for any enlightenment,

Hope you all had/are having a happy 4th July,

- Nick


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
