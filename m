Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:46512 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752953Ab0K2XfH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Nov 2010 18:35:07 -0500
From: <Daniel.Muntz@emc.com>
To: <spencer.shepler@gmail.com>, <Trond.Myklebust@netapp.com>,
        <spelic@shiftmail.org>
CC: <linux-nfs@vger.kernel.org>
Date: Mon, 29 Nov 2010 18:34:36 -0500
Subject: RE: NFSv4 behaviour on unknown users
Message-ID: <DE966DA98A4ABE438D726BDF1699CF610437B188E8@MX05A.corp.emc.com>
In-Reply-To: <067101cb9018$d70ba2f0$8522e8d0$@gmail.com>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I agree, no change is necessary, but I still don't like the wording of this paragraph :-)

   To avoid this mechanism being used to subvert user and
   group translation, so that a client might pass all of the owners and
   groups in numeric form, a server SHOULD return an NFS4ERR_BADOWNER
   error when there is a valid translation for the user or owner
   designated in this way.  In that case, the client must use the
   appropriate name@domain string and not the special form for
   compatibility."

  -Dan

-----Original Message-----
From: Spencer Shepler [mailto:spencer.shepler@gmail.com] 
Sent: Monday, November 29, 2010 2:58 PM
To: Muntz, Daniel; Trond.Myklebust@netapp.com; spelic@shiftmail.org
Cc: linux-nfs@vger.kernel.org
Subject: RE: NFSv4 behaviour on unknown users


Dan,

A change to the NFSv4.0 and NFSv4.1 RFCs is unnecessary.
What you suggest can be implemented today and still adhere
to the RFC text.  From RFC3530 (section 4.8) and RFC5661 (section 5.9)
the following text is quoted:

"  In the case where there is no translation available to the client or
   server, the attribute value will be constructed without the "@".
   Therefore, the absence of the @ from the owner or owner_group
   attribute signifies that no translation was available at the sender
   and that the receiver of the attribute should not use that string as
   a basis for translation into its own internal format.  Even though
   the attribute value cannot be translated, it may still be useful.  In
   the case of a client, the attribute string may be used for local
   display of ownership.

   To provide a greater degree of compatibility with NFSv3, which
   identified users and groups by 32-bit unsigned user identifiers and
   group identifiers, owner and group strings that consist of decimal
   numeric values with no leading zeros can be given a special
   interpretation by clients and servers that choose to provide such
   support.  The receiver may treat such a user or group string as
   representing the same user as would be represented by an NFSv3 uid or
   gid having the corresponding numeric value.  A server is not
   obligated to accept such a string, but may return an NFS4ERR_BADOWNER
   instead.  To avoid this mechanism being used to subvert user and
   group translation, so that a client might pass all of the owners and
   groups in numeric form, a server SHOULD return an NFS4ERR_BADOWNER
   error when there is a valid translation for the user or owner
   designated in this way.  In that case, the client must use the
   appropriate name@domain string and not the special form for
   compatibility."


I read this that if the implementation or administrator chooses
to op-out of the user@domain mapping, it may do so and the client
and server have a method available to them to communicate traditiona
uid/gid.

So, all that is needed now it seems is some code to provide the
option to the admin or as you suggest, change the default.

Spencer


> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Daniel.Muntz@emc.com
> Sent: Monday, November 29, 2010 2:09 PM
> To: Trond.Myklebust@netapp.com; spelic@shiftmail.org
> Cc: linux-nfs@vger.kernel.org
> Subject: RE: NFSv4 behaviour on unknown users
> 
> Looks like it's time for my annual numeric uid rant...
> 
> IMHO this was the silliest decision in the v4 spec, and a frequent
> hindrance to users wanting to move from v3.  Once again, I'm going to
> suggest that the v4.x series officially support numeric uid/gid strings as
> first-class user identifiers, rather than trying to force "name@domain" on
> systems that do not need this functionality, and are worse off for having
> to support it.  The fact that every OS needs different configuration to
> get it working just adds to the insanity.  Supply something that works
> (numeric id strings) as the default, but allow the name@domain
> "enhancement" for those who want it.  Then, everything just works, people
> seamlessly migrate to v4.x, and world peace is achieved.  There could even
> be an option to disable numeric id string support for those vehemently
> opposed to its existence, but at least in this case sysadmins have to go
> out of their way to make their system return nobody/nogroup for all users,
> rather than being the default behavior.
> 
>   -Dan
> 
> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Trond Myklebust
> Sent: Monday, November 29, 2010 10:23 AM
> To: Spelic
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: NFSv4 behaviour on unknown users
> 
> On Mon, 2010-11-29 at 19:12 +0100, Spelic wrote:
> > Hello all
> > we recently moved to nfsv4 from v3.
> >
> > I'm currently using idmapd and not kerberos.
> >
> > I noticed that now, with idmapd (and with idmapd is the only way I
> > know for configuring nfsv4 for now), users that are not known at
> > server side are squashed to nobody / nogroup  (65534 / 65534).
> > And a chown by root from the client fails if the user is not known at
> > server side.
> >
> > That's a problem... now we need ldap everywhere...
> >
> > We were often using NFS for exporting some diskspace to machines on an
> > as-needed basis, so this new behaviour complicates the things greatly
> > for us :-/ It's almost easier to setup iSCSI targets now :-((
> >
> > Is there a way to have nfsv4 with the behaviour of users of nfsv3,
> > that is, using numeric IDs instead of the names, like: "nfsserver,
> > don't care if you don't know the user, just give me the numeric ID for
> the file..."
> 
> No. That is not allowed by the spec.
> 
> Trond
> --
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html


