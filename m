From: "Roger Heflin" <rheflin@atipa.com>
Subject: RE: NFS and tinygrams
Date: Thu, 21 Oct 2004 16:22:21 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <EXCHG2003XZZTHfyQge000010c5@EXCHG2003.microtech-ks.com>
References: <1098391937.3601.304.camel@tesuji.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "'Linux NFS Mailing List'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CKkOT-0007EX-0S
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 14:22:45 -0700
Received: from host27-44.discord.birch.net ([65.16.27.44] helo=EXCHG2003.microtech-ks.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CKkOR-0007MX-H5
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 14:22:44 -0700
To: "'Dan Stromberg'" <strombrg@dcs.nac.uci.edu>,
	"'Lever, Charles'" <Charles.Lever@netapp.com>
In-Reply-To: <1098391937.3601.304.camel@tesuji.nac.uci.edu>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


>From what I have seen you need to umount and remount to get it to
use the jumbos.   It appears to me (someone correct me if this is 
wrong) that the MTU is set on a per connection basis when the
connection is initially established, and does not appear to change
once established, at least not in the upward direction.

                       Roger 

-----Original Message-----
From: nfs-admin@lists.sourceforge.net
[mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Dan Stromberg
Sent: Thursday, October 21, 2004 3:52 PM
To: Lever, Charles
Cc: Dan Stromberg; Linux NFS Mailing List
Subject: RE: [NFS] NFS and tinygrams


Yes, you're right.  I was on the wrong server - rxvt lied to me. 
hostname did not.

Upon doing a similar check on the Right server, it's become clear that while
our Redhat 9 host is doing jumbo frames, our RHEL 3 host is not.

I've set the MTU to 9000 on the RHEL 3 host.  Is there something else I need
to do to set jumbo frames on RHEL 3?  (The AIX 5.1 host this RHEL 3 host is
talking to, is doing jumbo frames fine with the Redhat 9 host, so I assume
the AIX 5.1 host is configured fine in this regard...)

Thanks!

> > Here are our packet lengths with counts, over 10000 packets:
> > 
> >   count packet length  
> >       3 70
> >       1 74
> >       2 82
> >       3 98
> >     164 182
> >     180 186
> >    8827 190
> >      76 202
> >     407 286
> >      52 4266
> >       1 7418
> >     284 8362
> > 
> > Does this look normal for a network with jumbo frames enabled 
> > transferring lots of mostly-large files?
> 
> you are confusing the network transport with the upper layer protocol.
> in addition i think you are looking at UDP traffic, not TCP.
> 
> note that 4266 = 170 + 4096, and that 8362 = 170 + 8192.  170 is the 
> size of the IP, UDP, RPC, and NFS headers, and the rest is the data 
> payload (multiple of the client's page size, 4096).  anything smaller 
> than 300 is likely to be an NFS metadata op (GETATTR, LOOKUP, and the 
> like).  that one 7000-odd byte packet is probably a READDIR.
> 
> if you want an analysis of the efficiency of the NFS client, use 
> "nfsstat -c" to decide whether your client is generating mostly 
> metadata ops, or whether these are really small reads and writes.
> 
> > On Thu, 2004-10-21 at 12:15, Dan Stromberg wrote:
> > > On Thu, 2004-10-21 at 11:56, Lever, Charles wrote:
> > > > > A tinygram is a small packet.
> > > > > 
> > > > > Many of the NFS packets I'm seeing are small - say about 200 
> > > > > or 300 bytes.  Then from time to time, there's a 7k packet, 
> > > > > like I'd like to see more of.
> > > > 
> > > > do you know what's in the small packets?  200 to 300 bytes are 
> > > > typical of most NFS operations (not READ or WRITE).  maybe your 
> > > > application is causing the client to generate lots of NFS
> > requests,
> > > > but only a few of them are WRITEs.
> > > 
> > > This is the NFS portion of a 190 byte packet, that appears to be 
> > > fairly representative, taken from tethereal:
> > > 
> > > Network File System
> > >     Program Version: 3
> > >     V3 Procedure: READ (6)
> > >     file
> > >         length: 36
> > >         hash: 0x3305e54e
> > >         type: unknown
> > >         data: 01000006007900411A00000000000000
> > >               001B8C1A000000000000000000057E72
> > >               00000000
> > >     offset: 1484812288
> > >     count: 8192
> > > 
> > > Most of the files in this filesystem are large (data from
> > simulation
> > > runs in netcdf format), but there certainly are some small ones.
> > > 
> > > Right now, our application is rsync.  But that may change later.
> > > 
> > > > > Someone just told me that netapp servers can do intent-based 
> > > > > NFS.  Do you concur?
> > > > 
> > > > i've never heard of "intent-based NFS."  can you explain
> > what this
> > > > means?
> > > 
> > > I believe it means that you bundle a bunch of operations
> > together into
> > > one large packet, and the execution of later operations is
> > contingent
> > > on the success of earlier operations (or perhaps more
> > generally, the
> > > exit status of earlier operations - not sure).
> > > 
> > > Lustre, I'm told, uses an intent-based protocol to speed up its 
> > > operations.
> > > 
> > > The FC2 nfs implementation (kernel 2.6.8-1) has a structure named 
> > > "intent", which -might- only be used in NFS v4.
> > > 
> > > There's some discussion of the data structure for intent-based NFS
> > > here:
> > > 
> > > http://seclists.org/lists/linux-kernel/2003/May/6040.html
> > > 
> > > Unfortunately, our AIX 5.1 machine does not support NFS v4.  
> > > Anyone know if AIX 5.3 does?  I'll ask on an AIX mailing list too...
> > > 
> > > > 
> > > > 
> > > > > On Thu, 2004-10-21 at 10:47, Lever, Charles wrote:
> > > > > > what's a "tinygram" ?
> > > > > > 
> > > > > > do you mean the NFS write requests aren't all "wsize" 
> > bytes?  or
> > > > > > do
> > > > > > you mean the TCP layer is segmenting into small IP packets? 
> > > > >  these are
> > > > > > two separate layers, and do not interact.
> > > > > > 
> > > > > > > -----Original Message-----
> > > > > > > From: Dan Stromberg [mailto:strombrg@dcs.nac.uci.edu]
> > > > > > > Sent: Thursday, October 21, 2004 1:05 PM
> > > > > > > To: Linux NFS Mailing List
> > > > > > > Cc: Dan Stromberg
> > > > > > > Subject: [NFS] NFS and tinygrams
> > > > > > > 
> > > > > > > 
> > > > > > > 
> > > > > > > We have a series of test transfers going, where we are 
> > > > > > > shuttling data from GFS->NFS V3 over UDP->NFS V3 over
> > > > > > > TCP->Lustre.
> > > > > > > 
> > > > > > > On the NFS V3 over TCP link, we're seeing a lot of
> > tinygrams,
> > > > > > > despite having 8K NFS block sizes turned on, and
> > jumbo packets
> > > > > > > enabled (9000 byte MTU).
> > > > > > > 
> > > > > > > The GFS machine runs Redhat 9, the first NFS server
> > also runs
> > > > > > > Redhat 9. The machine copying from NFS to NFS is
> > running AIX
> > > > > > > 5.1.  The machine copying NFS to Lustre is running RHEL 3.
> > > > > > > 
> > > > > > > I didn't check on the packet sizes of the other legs of 
> > > > > > > the transfer.
> > > > > > > 
> > > > > > > I've verified that we do have jumbo packets being
> > used some of
> > > > > > > the time, on that AIX 5.1 -> RHEL 3 hop.  However,
> > we're still
> > > > > > > getting a pretty large percentage of tinygrams.
> > > > > > > 
> > > > > > > Is there any way of cutting down on the tinygrams, to more 
> > > > > > > effectively utilize our large MTU?  Is there
> > perhaps any sort
> > > > > > > of "intent based" packetizing in standard
> > implementations of
> > > > > > > NFS on Redhat 9, AIX 5.1, and/or RHEL 3?
> > > > > > > 
> > > > > > > (Yes, we could short circuit the AIX 5.1 part of
> > the transfer,
> > > > > > > and that Would make things faster, but it Wouldn't
> > test what
> > > > > > > we need to test!)
> > > > > > > 
> > > > > > > Thanks!
> > > > > > > 
> > > > > > > --
> > > > > > > Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>
> > > > > > > 
> > > > > > > 
> > > > > > > 
> > > > > > > 
> > > > > > > -------------------------------------------------------
> > > > > > > This SF.net email is sponsored by: IT Product Guide on 
> > > > > > > ITManagersJournal Use IT products in your business? Tell 
> > > > > > > us what you think of them. Give us Your Opinions, Get Free 
> > > > > > > ThinkGeek Gift Certificates! Click to find out more 
> > > > > > > http://productguide.itmanagersjournal.com/guid> 
> > > > > > > epromo.tmpl
> > > > > > > 
> > > > > > > _______________________________________________
> > > > > > > 
> > > > > > > NFS maillist  -  NFS@lists.sourceforge.net 
> > > > > > > https://lists.sourceforge.net/lists/listinfo/n> fs
> > > > > > > 
> > > > > --
> > > > > Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>
> > > > > 
> > > > > 
> > --
> > Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>
> > 
> > 
> > 
--
Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>




-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
