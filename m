From: Adrian Bunk <bunk@stusta.de>
Subject: include/linux/nfsd/nfsfh.h: NULL dereference
Date: Sun, 12 Nov 2006 14:23:10 +0100
Message-ID: <20061112132310.GJ25057@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GjFIk-0005uc-Sh
	for nfs@lists.sourceforge.net; Sun, 12 Nov 2006 05:23:12 -0800
Received: from emailhub.stusta.mhn.de ([141.84.69.5]
	helo=mailout.stusta.mhn.de)
	by mail.sourceforge.net with smtp (Exim 4.44) id 1GjFIl-0001FK-L0
	for nfs@lists.sourceforge.net; Sun, 12 Nov 2006 05:23:12 -0800
To: neilb@cse.unsw.edu.au
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

The Coverity checker spotted the following:

<--  snip  -->

...
static __inline__ struct svc_fh *
fh_copy(struct svc_fh *dst, struct svc_fh *src)
{
        if (src->fh_dentry || src->fh_locked) {
                struct dentry *dentry = src->fh_dentry;
                printk(KERN_ERR "fh_copy: copying %s/%s, already verified!\n",
                        dentry->d_parent->d_name.name, dentry->d_name.name);
        }
                        
        *dst = *src;
        return dst;
}
...

<--  snip  -->

src->fh_dentry is being dereferenced when we discover it's NULL...

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
