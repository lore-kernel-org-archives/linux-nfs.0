From: =?gb2312?q?qiu=20linger?= <qiu_linger@yahoo.com.cn>
Subject: nfsroot nfs file locking problem
Date: Sat, 8 Mar 2003 10:51:17 +0800 (CST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030308025117.72286.qmail@web15212.mail.bjs.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=gb2312
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [61.135.128.142] (helo=web15212.mail.bjs.yahoo.com)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18rUR1-0007Ps-00
	for <nfs@lists.sourceforge.net>; Fri, 07 Mar 2003 18:51:39 -0800
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

	I am a Chinese,
          
	I have successed the nfs file locking on two PCs
running RH8.0, but when I applicate that to my embeded
platform,
I always fail that, my embeded platform, which run
2.4.4 kernel, and when to startup, mount to the
host(the same with PC)by nfsroot,as one diskless
system by nfsroot,as this;

#define CONFIG_CMDLINE "root=/dev/nfs
nfsroot=192.168.2.107:/home/zhangfq/7312/rfs.nfs
ip=192.168.2.117"


my code as this:

#include <math.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>
#include <dirent.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/file.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <iconv.h>

#define path "/root/test_bits"

struct flock* file_lock(short type, short whence)
{
         static struct flock ret ;

         ret.l_type = type ;
         ret.l_start = 0 ;
         ret.l_whence = whence ;
         ret.l_len = 0 ;
         ret.l_pid = getpid() ;
         return &ret ;
}

static void test_lock()
{
        //test fcntl
        int fd, rc;

        fd= open( path, O_RDWR,
S_IRWXU|S_IRWXG|S_IRWXO);
        if( fd== -1){ printf( "open file:%s fail
\n",path); return;};
        printf( "file:%s\n", path);

        rc= fcntl(fd, F_SETLKW, file_lock(F_WRLCK,
SEEK_SET));
        printf( "test_:fcntl return:%d\n", rc);
        while( 1){ sleep(1);};
        
        while( 1){
                rc= fcntl(fd, F_SETLKW,
file_lock(F_WRLCK, SEEK_SET));
                printf( "test_:fcntl return:%d\n",
rc);
                sleep(3);
                fcntl( fd, F_SETLK, file_lock(
F_UNLCK, SEEK_SET));
                sleep(3);
        }
}

int main()
{
	test_lock();
	return 0;
}



Please give me help!


thanks!

zhang faquan


_________________________________________________________
Do You Yahoo!? 
"用雅虎搜索，找到关于奥斯卡的一切"
http://cn.search.yahoo.com/search/cn?p=%b0%c2%cb%b9%bf%a8


-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
