Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53101 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932854Ab2LMOeo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Dec 2012 09:34:44 -0500
Date: Thu, 13 Dec 2012 09:34:38 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Suresh Jayaraman <sjayaraman@suse.com>
Cc: steved@redhat.com, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: idmapd doesn't map if the name (user or group) contains UTF8
 characters
Message-ID: <20121213143438.GA24855@fieldses.org>
References: <50C9AE0E.9070404@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50C9AE0E.9070404@suse.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 13, 2012 at 03:59:34PM +0530, Suresh Jayaraman wrote:
> Hi all,
> 
> While investigating a bug report from our customer where NFSv4 name to
> id mapping fails on the NFSv4 client (and maps to 'nobody') if a user or
> group name contains non-ASCII characters (in this case it was Umlaut
> characters) figured out we limit the characters to ASCII.
> 
> We seem to do this intentionally in utils/idmapd/idmapd.c: imconv()
> 
> ...
>         case IDMAP_CONV_NAMETOID:
>                 if (validateascii(im->im_name, sizeof(im->im_name)) == -1) {
>                         im->im_status |= IDMAP_STATUS_INVALIDMSG;
>                         return;
>                 }
> ...
> 
> with the validateacsii() function. I'm not sure why we had to limit the
> characters in the NFSv4 domain name to ASCII only. If I have to guess:
> 
>    - perhaps it is risky because the shell might expand some characters?
>    - Non-ASCII characters might have trouble between sharing systems
>      that may use different encodings
>    - to remain consistent with the tools like `groupadd' which considers
>      a name with these characters as Invalid names (not sure why
>      `groupadd' does so)
> 
> 
> However, there seems to be a valid use case for allowing such
> characters. For e.g. If Active Directory or LDAP is being used for
> authentication, both of them seem to allow Umlaut characters. When used
> together with such directory services, idmapd would end up mapping those
> users or groups to 'nobody'.
> 
> So my questions are:
> 
> 1) What is the reason behind not allowing non-ASCII characters?

I don't know why it's there either.  I don't think there's any reason
the kernel or other NFS code needs the check.

> 2) Is the limitation historical and is not relevant now? In such case
>    can we remove this check?
> 3) Would it make sense to allow atleast some UTF-8 characters that may
>    be non-risky?

I'd suggest just throwing away the check.

Even if we were to check for something else (like UTF-8, which is what
the v4 specs actually want), idmapd doesn't seem like the right place to
enforce restrictions on names.  Once the system has allowed a name it's
too late to be complaining about it here.

--b.
