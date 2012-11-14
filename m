Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:1978 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161007Ab2KNPVC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Nov 2012 10:21:02 -0500
Date: Wed, 14 Nov 2012 10:20:45 -0500 (EST)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: DENIEL Philippe <philippe.deniel@cea.fr>,
        Tomasz Chmielewski <mangoo@wpkg.org>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        tigran mkrtchyan <tigran.mkrtchyan@desy.de>
Message-ID: <824759489.0.1352906445144.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9092DFB2C@SACEXCMBX04-PRD.hq.netapp.com>
Subject: Re: xattr support in NFS?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Actually, that reasoning sounds a little like a concession that the feature should be blocked precisely because it may be tremendously popular (useful).  I don't think the argument that proplists can be the building blocks for new system--but also application--functionality is a good argument against them.

----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> On Wed, 2012-11-14 at 11:47 +0100, Tigran Mkrtchyan wrote:
> > That's bad news.... Currently we use 'magic files' to set/get user
> > specific metadata like number of events, space reservation    and
> > different file retention policies. The hope was that all could be
> done
> > with named attributes.
> >
> >  Tigran.
> >  
> 
> The setting and querying of retention policies is already covered in
> the
> NFSv4.1 protocol without any need for any additions. Space
> reservation
> is already covered in NFSv4.2 (as are security labels - another
> common
> hobby-horse for xattr advocates). Why don't you implement those
> instead
> of wishing for a completely different way of doing the same thing?
> 
> Your argument demonstrates precisely why we should never do xattrs
> over
> NFS. It makes it way too easy to go off and invent your own private
> and
> non-standard protocol for doing ioctl()-like RPC calls.
> 
> > On Tue, Nov 13, 2012 at 8:54 AM, DENIEL Philippe
> > <philippe.deniel@cea.fr> wrote:
> >         A few years ago, SGI tried to promote "NFS3 XATTR", an
> >         extension to NFSv3 to add xattr support. It roughly added 3
> >         functions to the protocol (GETXATTR, SETXATTR, LISTXATTR),
> in
> >         a similar way as what 9p.2000L does. Nothing but IRIX had
> this
> >         NFSv3 feature. As far as I know, it remained quite exotic
> and
> >         stayed a SGI's thing.
> >         
> >            Philippe
> >         
> >         Matt W. Benjamin a écrit :
> >         
> >                 Can you restate reasoning why it will never do so,
> and
> >                 whether this is the same as saying it will never
> >                 implement named attributes?
> >                 
> >                 Thanks,
> >                 
> >                 Matt
> >                 
> >                 ----- "Trond Myklebust"
> <Trond.Myklebust@netapp.com>
> >                 wrote:
> >                 
> >                   
> >                         No. We will never support xattrs over NFS.
> >                         
> >                             
> >                                 -----Original Message-----
> >                                 From:
> linux-nfs-owner@vger.kernel.org
> >                                 [mailto:linux-nfs-
> >                                 owner@vger.kernel.org] On Behalf Of
> >                                 Tomasz Chmielewski
> >                                 Sent: Monday, November 12, 2012
> 10:14
> >                                 AM
> >                                 To: linux-nfs@vger.kernel.org
> >                                 Subject: xattr support in NFS?
> >                                 
> >                                 Does Linux support xattr in NFS?
> >                                 
> >                                 IF tries using it in both NFS3 and
> >                                 NFS4 under Debian Lenny (2.6.32,
> >                                       
> >                         both
> >                             
> >                                 server and client), without
> success.
> >                                 
> >                                 # setfattr -n user.comment -v "this
> is
> >                                 a comment" /mnt/nfs
> >                                 setfattr: /mnt/nfs: Operation not
> >                                 supported
> >                                 
> >                                 
> >                                 --
> >                                 Tomasz Chmielewski
> >                                 http://blog.wpkg.org
> >                                 --
> >                                 To unsubscribe from this list: send
> >                                 the line "unsubscribe linux-nfs"
> >                                       
> >                         in the
> >                             
> >                                 body of a message to
> >                                 majordomo@vger.kernel.org More
> >                                 majordomo info
> >                                       
> >                         at
> >                             
> >                                
> http://vger.kernel.org/majordomo-info.html
> >                                       
> >                         N�����r��y���b�X��ǧv�^�)޺{.n�
> >                         +����{���"��^n�r���z���h����&���G���h�(�階
> >                         �ݢj"���m�����z�ޖ���f���h���~�m�
> >                             
> >                 
> >                   
> >         
> >         --
> >         To unsubscribe from this list: send the line "unsubscribe
> >         linux-nfs" in
> >         the body of a message to majordomo@vger.kernel.org
> >         More majordomo info at
> >          http://vger.kernel.org/majordomo-info.html
> >         
> > 
> > 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> N�����r��y���b�X��ǧv�^�)޺{.n�+����{���"��^n�r���z���h����&���G���h�(�階�ݢj"���m�����z�ޖ���f���h���~�m�

-- 
Matt Benjamin
The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel. 734-761-4689
fax. 734-769-8938
cel. 734-216-5309
