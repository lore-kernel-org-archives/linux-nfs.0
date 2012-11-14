Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:2013 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932448Ab2KNUNR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Nov 2012 15:13:17 -0500
Date: Wed, 14 Nov 2012 15:13:01 -0500 (EST)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: DENIEL Philippe <philippe.deniel@cea.fr>,
        Tomasz Chmielewski <mangoo@wpkg.org>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        tigran mkrtchyan <tigran.mkrtchyan@desy.de>
Message-ID: <9260316.73.1352923981222.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <440439536.71.1352923952209.JavaMail.root@thunderbeast.private.linuxbox.com>
Subject: Re: xattr support in NFS?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

feature - yes, an xattr like interface (though with NFSv4, I think I've tended to somewhat conflate in my mind the notions of xattr and named attribute, sorry).

Well, that's the thing.  An interface like xattr is generative.  I don't think the ceiling on use cases is desktop search programs.  The potential utility of the feature is something that comes to light over time, when you know you have the functionality available.  For example, the Ceph developers came up recently with an algorithm to store information related to links in a special xattr.  We've thought of exposing file checksum information as attributes.  My sense of how many potential uses there may be is related mostly, as with Tigran's remark, to the number of times I've heard someone say, "we could solve that with an xattr/named attribute."

You've said that xattrs and named attributes are completely different, but notwithstanding that, there seems to be logically quite a bit of overlap.  Clearly, the fact that the NFS protocol treats named attributes as subfiles is a detail that the client need not expose to applications.  It also seems as if an xattr interface is convenient for interacting with at a subset of named attributes (ones with tractable length names/values).  I mean, as I note, this is the proplist, and that has been a very successful interface in a lot of systems, going back a -long- ways.

Matt

----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> On Wed, 2012-11-14 at 10:20 -0500, Matt W. Benjamin wrote:
> > Actually, that reasoning sounds a little like a concession that the
> feature should be blocked precisely because it may be tremendously
> popular (useful).  I don't think the argument that proplists can be
> the building blocks for new system--but also
> application--functionality is a good argument against them.
> 
> What feature? The xattr interface? Before declaring it a major
> success
> story, you might want to consider that it has been implemented on
> several major Linux filesystems for more that 10 years, yet is used
> by
> only a handful of (non-portable) applications.
> 
> The main use-cases that I'm aware of are:
>       * Storage for ACLs.
>       * Storage for security labels.
>       * Samba uses xattrs for storing various per-file control
>         structures, when xattrs are supported by the underlying
>         filesystem.
>       * Storage for file search tags for use by programs such as
>         "beagle" and "tracker".
> 
> Both ACLs and security labels are already covered by the NFS
> protocol.
> We don't need or want an xattr protocol to solve those problems.
> 
> As for Samba, it works fine on filesystems that don't have xattrs as
> far
> as I know. Using it to re-export an NFS partition to CIFS is a
> dubious
> practice, but is not an xattr-related problem.
> 
> So that leaves the "beagle" and "tracker" use case, where the xattr
> usage for storing tags could easily be replaced by a database (and
> usually is in equivalent portable software). Most people who want to
> do
> serious work on their systems tend to turn off beagle and tracker
> anyway
> since they are notorious cpu hogs.
> 
> > ----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Wed, 2012-11-14 at 11:47 +0100, Tigran Mkrtchyan wrote:
> > > > That's bad news.... Currently we use 'magic files' to set/get
> user
> > > > specific metadata like number of events, space reservation   
> and
> > > > different file retention policies. The hope was that all could
> be
> > > done
> > > > with named attributes.
> > > >
> > > >  Tigran.
> > > >  
> > > 
> > > The setting and querying of retention policies is already covered
> in
> > > the
> > > NFSv4.1 protocol without any need for any additions. Space
> > > reservation
> > > is already covered in NFSv4.2 (as are security labels - another
> > > common
> > > hobby-horse for xattr advocates). Why don't you implement those
> > > instead
> > > of wishing for a completely different way of doing the same
> thing?
> > > 
> > > Your argument demonstrates precisely why we should never do
> xattrs
> > > over
> > > NFS. It makes it way too easy to go off and invent your own
> private
> > > and
> > > non-standard protocol for doing ioctl()-like RPC calls.
> > > 
> > > > On Tue, Nov 13, 2012 at 8:54 AM, DENIEL Philippe
> > > > <philippe.deniel@cea.fr> wrote:
> > > >         A few years ago, SGI tried to promote "NFS3 XATTR", an
> > > >         extension to NFSv3 to add xattr support. It roughly
> added 3
> > > >         functions to the protocol (GETXATTR, SETXATTR,
> LISTXATTR),
> > > in
> > > >         a similar way as what 9p.2000L does. Nothing but IRIX
> had
> > > this
> > > >         NFSv3 feature. As far as I know, it remained quite
> exotic
> > > and
> > > >         stayed a SGI's thing.
> > > >         
> > > >            Philippe
> > > >         
> > > >         Matt W. Benjamin a écrit :
> > > >         
> > > >                 Can you restate reasoning why it will never do
> so,
> > > and
> > > >                 whether this is the same as saying it will
> never
> > > >                 implement named attributes?
> > > >                 
> > > >                 Thanks,
> > > >                 
> > > >                 Matt
> > > >                 
> > > >                 ----- "Trond Myklebust"
> > > <Trond.Myklebust@netapp.com>
> > > >                 wrote:
> > > >                 
> > > >                   
> > > >                         No. We will never support xattrs over
> NFS.
> > > >                         
> > > >                             
> > > >                                 -----Original Message-----
> > > >                                 From:
> > > linux-nfs-owner@vger.kernel.org
> > > >                                 [mailto:linux-nfs-
> > > >                                 owner@vger.kernel.org] On Behalf
> Of
> > > >                                 Tomasz Chmielewski
> > > >                                 Sent: Monday, November 12, 2012
> > > 10:14
> > > >                                 AM
> > > >                                 To: linux-nfs@vger.kernel.org
> > > >                                 Subject: xattr support in NFS?
> > > >                                 
> > > >                                 Does Linux support xattr in
> NFS?
> > > >                                 
> > > >                                 IF tries using it in both NFS3
> and
> > > >                                 NFS4 under Debian Lenny
> (2.6.32,
> > > >                                       
> > > >                         both
> > > >                             
> > > >                                 server and client), without
> > > success.
> > > >                                 
> > > >                                 # setfattr -n user.comment -v
> "this
> > > is
> > > >                                 a comment" /mnt/nfs
> > > >                                 setfattr: /mnt/nfs: Operation
> not
> > > >                                 supported
> > > >                                 
> > > >                                 
> > > >                                 --
> > > >                                 Tomasz Chmielewski
> > > >                                 http://blog.wpkg.org
> > > >                                 --
> > > >                                 To unsubscribe from this list:
> send
> > > >                                 the line "unsubscribe
> linux-nfs"
> > > >                                       
> > > >                         in the
> > > >                             
> > > >                                 body of a message to
> > > >                                 majordomo@vger.kernel.org More
> > > >                                 majordomo info
> > > >                                       
> > > >                         at
> > > >                             
> > > >                                
> > > http://vger.kernel.org/majordomo-info.html
> > > >                                       
> > > >                         N�����r��y���b�X��ǧv�^�)޺{.n�
> > > >                        
> +����{���"��^n�r���z���h����&���G���h�(�階
>  <> >                         �ݢj"���m�����z�ޖ���f���h���~�m�
> > > >                             
> > > >                 
> > > >                   
> > > >         
> > > >         --
> > > >         To unsubscribe from this list: send the line
> "unsubscribe
> > > >         linux-nfs" in
> > > >         the body of a message to majordomo@vger.kernel.org
> > > >         More majordomo info at
> > > >          http://vger.kernel.org/majordomo-info.html
> > > >         
> > > > 
> > > > 
> > > 
> > > -- 
> > > Trond Myklebust
> > > Linux NFS client maintainer
> > > 
> > > NetApp
> > > Trond.Myklebust@netapp.com
> > > www.netapp.com
> > >
> N�����r��y���b�X��ǧv�^�)޺{.n�+����{���"��^n�r���z���h����&���G���h�(�階�ݢj"���m�����z�ޖ���f���h���~�m�
> > 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

-- 
Matt Benjamin
The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel. 734-761-4689
fax. 734-769-8938
cel. 734-216-5309
