From: Nilesh Simaria <nilesh@deeproot.co.in>
Subject: Need Little Help on mounting nfs using mount(2)
Date: Thu, 21 Nov 2002 18:13:34 +0000 (GMT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0211211811200.3320-100000@anubhav.lan.deeproot.co.in>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [202.71.150.112] (helo=deeproot.co.in)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18EqjZ-0000RV-00
	for <nfs@lists.sourceforge.net>; Thu, 21 Nov 2002 04:47:05 -0800
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


Hello,

I am using mount(2), to mount filesystems using C program. I am able
to do local mounts with that. But I dont know what to fill in
nfs_mount_data structure, to mount nfs filesystem.

Here is the piece of code, I am trying...
structure declarations, from nfs_mount4.h

struct nfs2_fh {
        char                    data[32];
};
struct nfs3_fh {
        unsigned short          size;
        unsigned char           data[64];
};

struct nfs_mount_data {
    int     version;
    int     fd;
    struct nfs2_fh  old_root;
    int     flags;
    int     rsize;
    int     wsize;
    int     timeo;
    int     retrans;
    int     acregmin;
    int     acregmax;
    int     acdirmin;
    int     acdirmax;
    struct  sockaddr_in addr;
    char    hostname[256];
    int     namlen;
    unsigned int    bsize;
    struct nfs3_fh  root;
};

int main()
{
	struct nfs_mount_data data;
	mount("192.168.1.102:/home/nilesh","/mnt/mp","nfs",0xC0ED0000,&data);
}

It dosent work and says Invalid arguments. Actually I dont know what to
fill in 'data'.

Can any one please tell me what should I fill in 'data' and pass it to
mount(2) API inorder to mount nfs partition.

Many thanks in advance
Nilesh.




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
