From: "Chris Pascoe" <c.pascoe@itee.uq.edu.au>
Subject: nfsd oops - exiting??
Date: Tue, 14 May 2002 12:13:52 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <00f301c1faec$fe0dd5f0$47426682@csee.uq.edu.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gum.csee.uq.edu.au ([130.102.66.1])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177RpA-00056h-00
	for <nfs@lists.sourceforge.net>; Mon, 13 May 2002 19:14:00 -0700
Received: from luma.csee.uq.edu.au (luma.csee.uq.edu.au [130.102.66.14])
	by gum.csee.uq.edu.au (8.11.6/8.11.6) with ESMTP id g4E2DqN11953
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 12:13:52 +1000 (EST)
Received: from SPIKE (spike.csee.uq.edu.au [130.102.66.71])
	by luma.csee.uq.edu.au (8.11.6/8.11.6) with SMTP id g4E2DqK16415
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 12:13:52 +1000 (EST)
To: <nfs@lists.sourceforge.net>
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

Hi,

After about 5 days of uptime on my SMP NFS server running 2.4.18+(CVS) XFS I
have experienced the following oops.  At least once before I have seen other
oopses that have occurred containing do_exit and sys_wait4, but I can't
obviously see how this code path was taken.  It goes without saying that I
can't reproduce the crash on demand..

Has anyone else seen similar traces and/or can suggest how the nfsd code got
to this point so I can attempt to investigate further?

The kernel is tainted by the Intel e1000 driver in the oops that follows.

Thanks,
Chris

--8<-- oops starts
Unable to handle kernel NULL pointer dereference at virtual address 00000286
c011be54
*pde = 00000000
Oops: 0002
CPU:    0
EIP:    0010:[<c011be54>]    Tainted: P
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010286
eax: 00000000   ebx: f71ec000   ecx: 00000001   edx: 00000286
esi: 00000000   edi: 00000286   ebp: f71edf94   esp: f71edf84
ds: 0018   es: 0018   ss: 0018
Process nfsd (pid: 889, stackpage=f71ed000)
Stack: f71ec000 00000000 00000000 f71ec000 f71edfac c011c6d6 00000286
f71ec000
       f7245ed4 f741ce00 f71edfb8 c011c84c 00000000 f7245edc c010722b
00000100
       c200b800 0000001f f7245ed4 f741ce00 f7245edc 00000001 f7440018
f71b0018
Call Trace: [<c011c6d6>] [<c011c84c>] [<c010722b>] [<c010588e>]
Code: f0 ff 0f 0f 94 c0 84 c0 0f 84 9e 00 00 00 c7 45 fc 00 00 00

>>EIP; c011be54 <put_files_struct+c/c4>   <=====
Trace; c011c6d6 <do_exit+12e/27c>
Trace; c011c84c <sys_wait4+0/3d8>
Trace; c010722b <system_call+33/38>
Trace; c010588e <kernel_thread+2a/38>
Code;  c011be54 <put_files_struct+c/c4>
00000000 <_EIP>:
Code;  c011be54 <put_files_struct+c/c4>   <=====
   0:   f0 ff 0f                  lock decl (%edi)   <=====
Code;  c011be57 <put_files_struct+f/c4>
   3:   0f 94 c0                  sete   %al
Code;  c011be5a <put_files_struct+12/c4>
   6:   84 c0                     test   %al,%al
Code;  c011be5c <put_files_struct+14/c4>
   8:   0f 84 9e 00 00 00         je     ac <_EIP+0xac> c011bf00
<put_files_struct+b8/c4>
Code;  c011be62 <put_files_struct+1a/c4>
   e:   c7 45 fc 00 00 00 00      movl   $0x0,0xfffffffc(%ebp)


_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
