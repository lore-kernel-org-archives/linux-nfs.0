From: "Rongqing \"Frank\" Tu" <rtu@packetgeneral.com>
Subject: Re: NFS digest, Vol 1 #1251 - 1 msg
Date: Sun, 1 Dec 2002 14:42:11 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0212011436560.3583-100000@filer.packetgeneral.com>
References: <E18H8QH-00057Z-00@sc8-sf-list2.sourceforge.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [204.52.248.2] (helo=filer.packetgeneral.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18IZz6-000859-00
	for <nfs@lists.sourceforge.net>; Sun, 01 Dec 2002 11:42:32 -0800
Received: from localhost (rtu@localhost)
	by filer.packetgeneral.com (8.11.6/8.11.6) with ESMTP id gB1JgBo03717
	for <nfs@lists.sourceforge.net>; Sun, 1 Dec 2002 14:42:11 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <E18H8QH-00057Z-00@sc8-sf-list2.sourceforge.net>
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

It seems the error # was not -EINVAL, but -EPERM.
I ever experieced the same error message and I debuged out that the error 
was caused by -EPERM, but I was on a differrent situation. I tried to 
export a mounted nfs point and I got this "permission denied" message.

Have you tried tracking the code?

Frank


On Wed, 27 Nov 2002 nfs-request@lists.sourceforge.net wrote:

> Send NFS mailing list submissions to
> 	nfs@lists.sourceforge.net
> 
> To subscribe or unsubscribe via the World Wide Web, visit
> 	https://lists.sourceforge.net/lists/listinfo/nfs
> or, via email, send a message with subject or body 'help' to
> 	nfs-request@lists.sourceforge.net
> 
> You can reach the person managing the list at
> 	nfs-admin@lists.sourceforge.net
> 
> When replying, please edit your Subject line so it is more specific
> than "Re: Contents of NFS digest..."
> 
> 
> Today's Topics:
> 
>    1. Error mounting nfs clients (Albers, Lucas)
> 
> --__--__--
> 
> Message: 1
> From: "Albers, Lucas" <luke@coe.montana.edu>
> To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
> Cc: "'Valhalla-list@redhat.com'" <Valhalla-list@redhat.com>
> Date: Wed, 27 Nov 2002 11:50:02 -0700
> Subject: [NFS] Error mounting nfs clients
> 
> I have been running an nfs server for a number of months.
> Every couple of days I get the following error message in my logs:
> 
> Hostname rpc.mountd: getfh failed: Operation not permitted
> 
> When this happens the clients are unable to mount the nfs exported volumes.
> Restarting the service will fix the problem.
> 
> 
> After researching the issue.
> It appears that the error is related to the defined value:
> 	NFS_FHSIZE 
> in the code listed below in this file:
> /usr/src/linux-2.4.18-5/fs/nfsd/nfsctl.c
> 
> /*-----------------------------------------------------*/
>         if (err == 0) {
>                 if (fh.fh_size > NFS_FHSIZE)
>                         err = -EINVAL;
> /*-----------------------------------------------------*/
> 
> It appears that raising the value:
> 
> #define NFS_FHSIZE      32
> 
> Defined in /usr/include/linux/nfs.h
> Would fix the problem.
> 
> Server Information
> Kernel 2.4.18-5 with NFS compiled in.
> Clients are all 7.3 and 8.0 RedHat machines.
> I am running 16 nfsd daemons on the server.
> Usually between 200 and 280 clients are mounting volumes at one time.
> Usually only between 20-30 clients are doing anything with their mounted
> volumes.
> 
> Does anyone have any idea, what exactly is happening to cause this problem?
> 
> 
> see complete code snippet below:
> -------------------------------------
> 
> static inline int
> nfsctl_getfh(struct nfsctl_fhparm *data, __u8 *res)
> {
>         struct sockaddr_in      *sin;
>         struct svc_client       *clp;
>         int                     err = 0;
>         struct knfsd_fh         fh;
> 
>         if (data->gf_addr.sa_family != AF_INET)
>                 return -EPROTONOSUPPORT;
>         if (data->gf_version < 2 || data->gf_version > NFSSVC_MAXVERS)
>                 return -EINVAL;
>         sin = (struct sockaddr_in *)&data->gf_addr;
> 
>         exp_readlock();
>         if (!(clp = exp_getclient(sin)))
>                 err = -EPERM;
>         else
>                 err = exp_rootfh(clp, to_kdev_t(data->gf_dev), data->gf_ino,
> NULL, &fh, NFS_FHSIZE);
>         exp_readunlock();
> /*-----------------------------------------------------*/
>         if (err == 0) {
>                 if (fh.fh_size > NFS_FHSIZE)
>                         err = -EINVAL;
> /*-----------------------------------------------------*/
>                 else {
>                         memset(res,0, NFS_FHSIZE);
>                         memcpy(res, &fh.fh_base, fh.fh_size);
>                 }
>         }
> 
>         return err;
> }
> -------------------------------------
> 
> 
> 
> > --Luke
> > --Computer Science Sysadmin, MSU Bozeman 
> > --admin(AT)cs.montana.edu 994-3931 
> 
> 
> 
> 
> --__--__--
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 
> 
> End of NFS Digest
> 



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
