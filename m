From: "Metathronius Galabant" <m.galabant@googlemail.com>
Subject: NFS: double dentries in directory with 2.6.20
Date: Fri, 16 Mar 2007 14:00:23 +0100
Message-ID: <1b270aae0703160600t5a458084p76697d74872f0cb3@mail.gmail.com>
References: <1b270aae0703160559r794cc36ake0248d71569cb5b8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: NFS@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: <1b270aae0703160559r794cc36ake0248d71569cb5b8@mail.gmail.com>
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

Hi,

today I experienced double directory entries from a NFS mounted dir,
e.g. the file "file1.ext" is listed *twice* in the output.

The following under a 2.6.20 NFS client; Server was 2.6.18.8, NFS over UDP.
Mountpoint was not superblock-shared because it was a unique mount.

ls output:

drwxr-xr-x  3 user grp  296 Mar 15 17:28 ./
drwxr-xr-x  3 user grp  296 Mar 15 17:28 ./
drwxr-xr-x  3 user grp   72 Mar 15 17:28 ../
drwxr-xr-x  3 user grp   72 Mar 15 17:28 ../
drwxr-xr-x  2 user grp   80 Mar 15 17:28 00001/
drwxr-xr-x  2 user grp   80 Mar 15 17:28 00001/
-rw-r--r--  1 user grp  357 Mar 15 17:28 00001.patterns.pvset
-rw-r--r--  1 user grp 2057 Mar 15 17:28 00001.proc.pbs
-rw-r--r--  1 user grp   66 Mar 15 17:28 00001.proc.pbs.dep
-rw-r--r--  1 user grp   23 Mar 15 17:28 00001.proc.pbs.id
-rw-r--r--  1 user grp    0 Mar 15 17:28 00001.proc.pbs.queued
-rw-r--r--  1 user grp    0 Mar 15 17:28 00001.proc.pbs.queued
-rw-r--r--  1 user grp  784 Mar 15 17:28 00001.proc.pvset

strace for getdents():

getdents64(3, {{d_ino=14652528, d_off=1, d_type=DT_DIR, d_reclen=24,
d_name="."} {d_ino=14652526, d_off=2, d_type=DT_DIR, d_reclen=24,
d_name=".."} {d_ino=14654778, d_off=3, d_type=DT_DIR, d_reclen=32,
d_name="00001"} {d_ino=14656129, d_off=4, d_type=DT_REG, d_reclen=48,
d_name="00001.proc.pbs.queued"} {d_ino=14652528, d_off=5,
d_type=DT_DIR, d_reclen=24, d_name="."} {d_ino=14652526, d_off=6,
d_type=DT_DIR, d_reclen=24, d_name=".."} {d_ino=14654778, d_off=7,
d_type=DT_DIR, d_reclen=32, d_name="00001"} {d_ino=14656129, d_off=8,
d_type=DT_REG, d_reclen=48, d_name="00001.proc.pbs.queued"}
{d_ino=14656022, d_off=9, d_type=DT_REG, d_reclen=40,
d_name="00001.proc.pbs.id"} {d_ino=14654835, d_off=10, d_type=DT_REG,
d_reclen=40, d_name="00001.proc.pbs.dep"} {d_ino=14654838, d_off=11,
d_type=DT_REG, d_reclen=40, d_name="00001.proc.pvset"}
{d_ino=14654841, d_off=12, d_type=DT_REG, d_reclen=40,
d_name="00001.patterns.pvset"} {d_ino=14654832, d_off=13,
d_type=DT_REG, d_reclen=40, d_name="00001.proc.pbs"}}, 32768) = 456

Only umounting and remounting did cure the problem which hasn't
reappeared as of now. The problem seemed to be localized into one
directory.

ATM I don't know how to track that down or supply any more information.
Please include me on CC.

Cheers,
M

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
