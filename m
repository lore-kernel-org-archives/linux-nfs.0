From: "Albers, Lucas" <luke@coe.montana.edu>
Subject: Error mounting nfs clients
Date: Wed, 27 Nov 2002 11:50:02 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E2A41F3CFE5FD411ABC900508BAE0BEE02CAF4F2@power.coe.montana.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "'Valhalla-list@redhat.com'" <Valhalla-list@redhat.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from power.coe.montana.edu ([153.90.194.2])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18H7GH-0007PE-00
	for <nfs@lists.sourceforge.net>; Wed, 27 Nov 2002 10:50:13 -0800
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

I have been running an nfs server for a number of months.
Every couple of days I get the following error message in my logs:

Hostname rpc.mountd: getfh failed: Operation not permitted

When this happens the clients are unable to mount the nfs exported volumes.
Restarting the service will fix the problem.


After researching the issue.
It appears that the error is related to the defined value:
	NFS_FHSIZE 
in the code listed below in this file:
/usr/src/linux-2.4.18-5/fs/nfsd/nfsctl.c

/*-----------------------------------------------------*/
        if (err == 0) {
                if (fh.fh_size > NFS_FHSIZE)
                        err = -EINVAL;
/*-----------------------------------------------------*/

It appears that raising the value:

#define NFS_FHSIZE      32

Defined in /usr/include/linux/nfs.h
Would fix the problem.

Server Information
Kernel 2.4.18-5 with NFS compiled in.
Clients are all 7.3 and 8.0 RedHat machines.
I am running 16 nfsd daemons on the server.
Usually between 200 and 280 clients are mounting volumes at one time.
Usually only between 20-30 clients are doing anything with their mounted
volumes.

Does anyone have any idea, what exactly is happening to cause this problem?


see complete code snippet below:
-------------------------------------

static inline int
nfsctl_getfh(struct nfsctl_fhparm *data, __u8 *res)
{
        struct sockaddr_in      *sin;
        struct svc_client       *clp;
        int                     err = 0;
        struct knfsd_fh         fh;

        if (data->gf_addr.sa_family != AF_INET)
                return -EPROTONOSUPPORT;
        if (data->gf_version < 2 || data->gf_version > NFSSVC_MAXVERS)
                return -EINVAL;
        sin = (struct sockaddr_in *)&data->gf_addr;

        exp_readlock();
        if (!(clp = exp_getclient(sin)))
                err = -EPERM;
        else
                err = exp_rootfh(clp, to_kdev_t(data->gf_dev), data->gf_ino,
NULL, &fh, NFS_FHSIZE);
        exp_readunlock();
/*-----------------------------------------------------*/
        if (err == 0) {
                if (fh.fh_size > NFS_FHSIZE)
                        err = -EINVAL;
/*-----------------------------------------------------*/
                else {
                        memset(res,0, NFS_FHSIZE);
                        memcpy(res, &fh.fh_base, fh.fh_size);
                }
        }

        return err;
}
-------------------------------------



> --Luke
> --Computer Science Sysadmin, MSU Bozeman 
> --admin(AT)cs.montana.edu 994-3931 



-------------------------------------------------------
This SF.net email is sponsored by: Get the new Palm Tungsten T 
handheld. Power & Color in a compact size! 
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0002en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
