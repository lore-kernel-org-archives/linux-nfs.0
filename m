From: Abhishek Rai <abbashake007@yahoo.com>
Subject: Unable to handle kernel NULL pointer dereference at virtual address ..
Date: Wed, 23 Apr 2003 11:14:04 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030423181404.15518.qmail@web11403.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web11403.mail.yahoo.com ([216.136.131.233])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 198Okv-0003Vg-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Apr 2003 11:14:05 -0700
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi,
   this time I've attached a complete ksymoops output
for the error i am encountering again and again. The
error is in a small hack for the linux kernel's nfs
module which was working just fine before i added the
following code which works till a point.

static void nfs_print_path(struct dentry *d) {
	struct dentry *parent;
        struct qstr *qs;
        char name[64];
        struct inode *inode_parent, *inode;
        void *p, *me;
        if(!d) { 
              return;
        }       
        parent = d->d_parent;
        qs = &d->d_name;
                        
        if(parent)  {
              inode_parent = parent->d_inode;
              inode = d->d_inode;
              p = (void *)inode_parent;
              me = (void *)inode;
// Till here things work just fine. I am DEAD SURE of
that as i put printk()
// followed by return here and there and checked.
// My analysis with printk's and return's shows that
the next statement, or somewhere
// after that is the problem. ksymoops identifies the
fault triggering instrxn as
// 'cmp' (see output below) which (??) could be for
this statement.
             if( p - me != 0 ) {
                     printk("return 3\n");
                     return;
             }




KSYMOOPS OUTPUT:

<1>Unable to handle kernel NULL pointer dereference at
                             virtual address 0000000f
                             c88b6956
                             *pde = 00000000
                             Oops: 0000
                             CPU:    0
                             EIP:    0010:[<c88b6956>]
   Not tainted
                             Using defaults from
ksymoops -t elf32-i386 -a i386
                             EFLAGS: 00010202
                             eax: 00000006   ebx:
c6675024   ecx: 00000001   edx:
                             00000007
                             esi: 429d3663   edi:
0000005d   ebp: c6598cdc   esp:
                             c5b21f08
                             ds: 0018   es: 0018   ss:
0018
                             Process ls (pid: 1996,
stackpage=c5b21000)
                             Stack: 00000246 ffffffd2
c011b91b 0001ea92 0001ea96
                             00000282 0001ea96
0001ea8f 
                                    00000001 00000282
00000001 c033c964 00000000
                             00000004 c6598cdc
c011bb41 
                                    c6675044 429d3663
c6675044 c88b80e2 c6675024
                             bffff930 c014f67e
c71bf000 
                             Call Trace: [<c011b91b>]
[<c011bb41>] [<c88b80e2>]
                             [<c014f67e>] [<c0151111>]

                                [<c014cd04>]
[<c010775c>] [<c010766b>] 
                             Code: 39 42 08 74 0d 83
ec 0c 68 2c 81 8c c8 eb 0b 8d
                             76 00 83 ec 

                             >>EIP; c88b6956
<[nfs]nfs_print_path+2e/58> <=====
                             Trace; c011b91b
<call_console_drivers+eb/100>
                             Trace; c011bb41
<printk+1a1/1f0>
                             Trace; c88b80e2
<[nfs]nfs_revalidate+116/1b0>
                             Trace; c014f67e
<getname+5e/a0>
                             Trace; c0151111
<__user_walk+41/50>
                             Trace; c014cd04
<sys_lstat64+34/70>
                             Trace; c010775c
<error_code+34/3c>
                             Trace; c010766b
<system_call+33/38>
                             Code;  c88b6956
<[nfs]nfs_print_path+2e/58>
                             00000000 <_EIP>:
                             Code;  c88b6956
<[nfs]nfs_print_path+2e/58> <=====
                                0:   39 42 08         
        cmp   
                             %eax,0x8(%edx)   <=====
                             Code;  c88b6959
<[nfs]nfs_print_path+31/58>
                             3:   74 0d               
     je     12 <_EIP+0x12>
                             c88b6968
<[nfs]nfs_print_path+40/58>
                             Code;  c88b695b
<[nfs]nfs_print_path+33/58>
                             5:   83 ec 0c            
     sub    $0xc,%esp
                             Code;  c88b695e
<[nfs]nfs_print_path+36/58>
                             8:   68 2c 81 8c c8      
     push   $0xc88c812c
                             Code;  c88b6963
<[nfs]nfs_print_path+3b/58>
                             d:   eb 0b               
     jmp    1a <_EIP+0x1a>
                             c88b6970
<[nfs]nfs_print_path+48/58>
                             Code;  c88b6965
<[nfs]nfs_print_path+3d/58>
                             f:   8d 76 00            
     lea    0x0(%esi),%esi
                             Code;  c88b6968
<[nfs]nfs_print_path+40/58>
                             12:   83 ec 00           
      sub    $0x0,%esp




so whats so wrong. as per what ksymoops says, the
final error is triggered by a 'cmp' instruction: a
mere register operation.
if this is found insufficient could u tell me some
better kernel debugger(i use only ksymoops).

regards
abhishek


__________________________________________________
Do you Yahoo!?
The New Yahoo! Search - Faster. Easier. Bingo
http://search.yahoo.com


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
