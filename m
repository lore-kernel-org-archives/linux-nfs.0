From: "Lucas Albers" <admin@cs.montana.edu>
Subject: RE: Re: NFS digest, Vol 1 #1251 - 1 msg
Date: Mon, 2 Dec 2002 11:06:24 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E2A41F3CFE5FD411ABC900508BAE0BEE02753C22@power.coe.montana.edu>
References: <Pine.LNX.4.44.0212011436560.3583-100000@filer.packetgeneral.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: "'Rongqing \"Frank\" Tu'" <rtu@packetgeneral.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from esus.cs.montana.edu ([153.90.199.47] ident=[f5ee10qBhQRu4AR4CK6jW27Ek5z02O27])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Iuxp-0007PY-00
	for <nfs@lists.sourceforge.net>; Mon, 02 Dec 2002 10:06:38 -0800
To: <nfs@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.4.44.0212011436560.3583-100000@filer.packetgeneral.com>
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

I tried turning off nfs version 1 and 2 to try and solve this problem.
This had the unforeseen effect of killing my nis server.
For that reason I have had to go back to exporting all versions of nfs
v1,v2,v3.

I am not sure what the actual cause of the error message was in this
particular problem.
Trond said it was related to the mounting of the filesystem by the
client:
------------------

> From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
> Sent: Wednesday, November 27, 2002 1:47 PM
> If you do that, you will no longer be running NFSv2. Under NFSv2, file
> handle sizes are 32 bytes long, no more, no less...
> 
> If the filesystem you are using needs to generate filehandles that are
> greater that 32 bytes long, then you will probably only be able to use
> it with NFSv3
 
------------------------
It appears thec clients are needing to generate filehandles that are
longer then 32 bytes long?
This is causing the error message, long filenames?


> -----Original Message-----
> From: nfs-admin@lists.sourceforge.net [mailto:nfs-
> admin@lists.sourceforge.net] On Behalf Of Rongqing "Frank" Tu
> Sent: Sunday, December 01, 2002 12:42 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] Re: NFS digest, Vol 1 #1251 - 1 msg
> 
> It seems the error # was not -EINVAL, but -EPERM.
> I ever experieced the same error message and I debuged out that the
error
> was caused by -EPERM, but I was on a differrent situation. I tried to
> export a mounted nfs point and I got this "permission denied" message.
> 
> Have you tried tracking the code?
> 
> Frank
> 
> 
> On Wed, 27 Nov 2002 nfs-request@lists.sourceforge.net wrote:
> 
> > Send NFS mailing list submissions to
> > 	nfs@lists.sourceforge.net
> >
> > To subscribe or unsubscribe via the World Wide Web, visit
> > 	https://lists.sourceforge.net/lists/listinfo/nfs
> > or, via email, send a message with subject or body 'help' to
> > 	nfs-request@lists.sourceforge.net
> >
> > You can reach the person managing the list at
> > 	nfs-admin@lists.sourceforge.net
> >
> > When replying, please edit your Subject line so it is more specific
> > than "Re: Contents of NFS digest..."
> >
> >
> > Today's Topics:
> >
> >    1. Error mounting nfs clients (Albers, Lucas)
> >
> > --__--__--
> >
> > Message: 1
> > From: "Albers, Lucas" <luke@coe.montana.edu>
> > To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
> > Cc: "'Valhalla-list@redhat.com'" <Valhalla-list@redhat.com>
> > Date: Wed, 27 Nov 2002 11:50:02 -0700
> > Subject: [NFS] Error mounting nfs clients
> >
> > I have been running an nfs server for a number of months.
> > Every couple of days I get the following error message in my logs:
> >
> > Hostname rpc.mountd: getfh failed: Operation not permitted
> >
> > When this happens the clients are unable to mount the nfs exported
> volumes.
> > Restarting the service will fix the problem.
> >
> >
> > After researching the issue.
> > It appears that the error is related to the defined value:
> > 	NFS_FHSIZE
> > in the code listed below in this file:
> > /usr/src/linux-2.4.18-5/fs/nfsd/nfsctl.c
> >
> > /*-----------------------------------------------------*/
> >         if (err == 0) {
> >                 if (fh.fh_size > NFS_FHSIZE)
> >                         err = -EINVAL;
> > /*-----------------------------------------------------*/
> >
> > It appears that raising the value:
> >
> > #define NFS_FHSIZE      32
> >
> > Defined in /usr/include/linux/nfs.h
> > Would fix the problem.
> >
> > Server Information
> > Kernel 2.4.18-5 with NFS compiled in.
> > Clients are all 7.3 and 8.0 RedHat machines.
> > I am running 16 nfsd daemons on the server.
> > Usually between 200 and 280 clients are mounting volumes at one
time.
> > Usually only between 20-30 clients are doing anything with their
mounted
> > volumes.
> >
> > Does anyone have any idea, what exactly is happening to cause this
> problem?
> >
> >
> > see complete code snippet below:
> > -------------------------------------
> >
> > static inline int
> > nfsctl_getfh(struct nfsctl_fhparm *data, __u8 *res)
> > {
> >         struct sockaddr_in      *sin;
> >         struct svc_client       *clp;
> >         int                     err = 0;
> >         struct knfsd_fh         fh;
> >
> >         if (data->gf_addr.sa_family != AF_INET)
> >                 return -EPROTONOSUPPORT;
> >         if (data->gf_version < 2 || data->gf_version >
NFSSVC_MAXVERS)
> >                 return -EINVAL;
> >         sin = (struct sockaddr_in *)&data->gf_addr;
> >
> >         exp_readlock();
> >         if (!(clp = exp_getclient(sin)))
> >                 err = -EPERM;
> >         else
> >                 err = exp_rootfh(clp, to_kdev_t(data->gf_dev), data-
> >gf_ino,
> > NULL, &fh, NFS_FHSIZE);
> >         exp_readunlock();
> > /*-----------------------------------------------------*/
> >         if (err == 0) {
> >                 if (fh.fh_size > NFS_FHSIZE)
> >                         err = -EINVAL;
> > /*-----------------------------------------------------*/
> >                 else {
> >                         memset(res,0, NFS_FHSIZE);
> >                         memcpy(res, &fh.fh_base, fh.fh_size);
> >                 }
> >         }
> >
> >         return err;
> > }
> > -------------------------------------
> >
> >
> >
> > > --Luke
> > > --Computer Science Sysadmin, MSU Bozeman
> > > --admin(AT)cs.montana.edu 994-3931
> >
> >
> >
> >
> > --__--__--
> >
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >
> >
> > End of NFS Digest
> >
> 
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This SF.net email is sponsored by: Get the new Palm Tungsten T 
handheld. Power & Color in a compact size! 
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0002en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
