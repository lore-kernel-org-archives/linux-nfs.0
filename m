From: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
Subject: oops in nfs_complete_unlink
Date: Fri, 12 Jul 2002 10:16:52 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8D7D56C6ED3DD411998D009027DC685E04664E7E@srv-grp-s1.segin.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from hermes7.atos-group.com ([160.92.18.56] helo=hermes7.axime.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Svbm-0003Z2-00
	for <nfs@lists.sourceforge.net>; Fri, 12 Jul 2002 01:16:58 -0700
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

ksymoops 2.4.5 on i686 2.4.18-xfs-1.1.  Options used
     -v /boot/vmlinux-2.4.18-xfs-1.1 (specified)
     -k /proc/ksyms (default)
     -l /proc/modules (default)
     -o /lib/modules/2.4.18-xfs-1.1/ (default)
     -m /boot/System.map-2.4.18-xfs-1.1 (specified)

Reading Oops report from the terminal
Unable to handle kernel paging request at virtual address 6d20666d
c016d89e
*pde = 00000000
Oops: 0000
CPU:    0
EIP:    0010:[<c016d89e>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010206
eax: e39d1cc0   ebx: 6d206665   ecx: 00000000   edx: e39d1cc0
esi: e28c4d60   edi: f6120e20   ebp: e39d1cc0   esp: d19f5f3c
ds: 0018   es: 0018   ss: 0018
Process lmtpd (pid: 10904, stackpage=d19f5000)
Stack: d19f4000 e28c4d60 f6120e20 e39d1cc0 d19f5f4c c01669a4 e39d1cc0
e39d1cc0 
       e28c4d60 c01498ea e39d1cc0 e28c4d60 d9871d40 e28c4d60 c01379be
e39d1cc0 
       d9871d40 d19f4000 00000000 bfffcc0c c01365a7 d9871d40 c6f5cca0
00000000 
Call Trace: [<c01669a4>] [<c01498ea>] [<c01379be>] [<c01365a7>] [<c013660f>]

   [<c010705b>] 
Code: 3b 53 08 75 ed 85 db 0f 84 88 00 00 00 ff 83 a4 00 00 00 8b 


>>EIP; c016d89e <nfs_complete_unlink+32/d4>   <=====

>>eax; e39d1cc0 <_end+2360d184/384be4c4>
>>ebx; 6d206665 Before first symbol
>>edx; e39d1cc0 <_end+2360d184/384be4c4>
>>esi; e28c4d60 <_end+22500224/384be4c4>
>>edi; f6120e20 <_end+35d5c2e4/384be4c4>
>>ebp; e39d1cc0 <_end+2360d184/384be4c4>
>>esp; d19f5f3c <_end+11631400/384be4c4>

Trace; c01669a4 <nfs_dentry_iput+3c/80>
Trace; c01498ea <dput+da/144>
Trace; c01379be <fput+c6/e8>
Trace; c01365a7 <filp_close+9b/a4>
Trace; c013660f <sys_close+5f/74>
Trace; c010705b <system_call+33/38>

Code;  c016d89e <nfs_complete_unlink+32/d4>
00000000 <_EIP>:
Code;  c016d89e <nfs_complete_unlink+32/d4>   <=====
   0:   3b 53 08                  cmp    0x8(%ebx),%edx   <=====
Code;  c016d8a1 <nfs_complete_unlink+35/d4>
   3:   75 ed                     jne    fffffff2 <_EIP+0xfffffff2> c016d890
<nfs_complete_unlink+24/d4>
Code;  c016d8a3 <nfs_complete_unlink+37/d4>
   5:   85 db                     test   %ebx,%ebx
Code;  c016d8a5 <nfs_complete_unlink+39/d4>
   7:   0f 84 88 00 00 00         je     95 <_EIP+0x95> c016d933
<nfs_complete_unlink+c7/d4>
Code;  c016d8ab <nfs_complete_unlink+3f/d4>
   d:   ff 83 a4 00 00 00         incl   0xa4(%ebx)
Code;  c016d8b1 <nfs_complete_unlink+45/d4>
  13:   8b 00                     mov    (%eax),%eax
 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Gadgets, caffeine, t-shirts, fun stuff.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
