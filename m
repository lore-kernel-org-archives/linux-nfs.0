Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from msux-gh1-uea02.nsa.gov ([63.239.65.40]:42010 "EHLO
	msux-gh1-uea02.nsa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755190Ab0GLOhI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 10:37:08 -0400
Subject: Re: [PATCH 06/10] NFSv4: Add label recommended attribute and NFSv4
 flags
From: Stephen Smalley <sds@tycho.nsa.gov>
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: Kyle Moffett <kyle@moffetthome.net>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        James Morris <jmorris@namei.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, hch@infradead.org,
        viro@zeniv.linux.org.uk, matthew.dodd@sparta.com,
        trond.myklebust@fys.uio.no, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-security-module@vger.kernel.org,
        selinux@tycho.nsa.gov, linux-nfs@vger.kernel.org
In-Reply-To: <4C3952D6.7040608@schaufler-ca.com>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
	 <1278513086-23964-7-git-send-email-dpquigl@tycho.nsa.gov>
	 <20100707170058.GD28815@fieldses.org>
	 <alpine.LRH.2.00.1007080928180.14102@tundra.namei.org>
	 <1278596363.2494.194.camel@moss-terrapins.epoch.ncsc.mil>
	 <alpine.LRH.2.00.1007090834190.23354@tundra.namei.org>
	 <1278684348.2494.223.camel@moss-terrapins.epoch.ncsc.mil>
	 <AANLkTinUO-xqvQQINTzKLcXnljq-RaN5X6ulEAqvuf0d@mail.gmail.com>
	 <4C3952D6.7040608@schaufler-ca.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 12 Jul 2010 10:36:36 -0400
Message-ID: <1278945396.5221.14.camel@moss-pluto.epoch.ncsc.mil>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2010-07-10 at 22:12 -0700, Casey Schaufler wrote:
> Kyle Moffett wrote:
> > ...
> > Even in local filesystems like ext3 we prefer to turn labels into
> > numbers, store the number with each inode, and then keep the labels
> > indexed in a separate datastructure.
> >   
> 
> I don't know what system you're talking about, but that notion
> was pretty well dispelled in the late 1980's, after the SystemV/MLS
> and SecureWare examples.

SELinux did that too before switching to using xattrs for label storage.
Persistent security identifier (PSID) associated with each inode (either
stored directly in the inode in the original kernel patches or
associated through a separate mapping in the LSM-based implementation),
with a mapping from PSID to context stored in a mapping within each
filesystem.  Allowed you to keep the labels with the volume but avoided
storing the same label multiple times.

The xattr based implementation can sometimes share storage but only when
the xattr is stored in the additional block (not when they are stored
inline) and only if all of the xattrs on the file are identical.

> > Cheers,
> > Kyle Moffett
> >
> >
> >   

-- 
Stephen Smalley
National Security Agency

