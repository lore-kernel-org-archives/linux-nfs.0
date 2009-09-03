From: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Subject: RE: VM issue causing high CPU loads
Date: Thu, 3 Sep 2009 14:21:18 -0700
Message-ID: <7A24DF798E223B4C9864E8F92E8C93EC03F0AFB3@SACMVEXC1-PRD.hq.netapp.com>
References: <20090903200550.GB5257@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Yohan" <ytordjman-CZvJ5kAzflf985uAA1p3mw@public.gmane.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	<linux-kernel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
	"Neil Brown" <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, <mikevs@xs4all.net>
To: "Simon Kirby" <sim@hostway.ca>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61013 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932278AbZICVWB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Sep 2009 17:22:01 -0400
In-Reply-To: <20090903200550.GB5257@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Amen.  I understand that v4 wants to extend across domains, etc., but it
goes out of its way to prevent the use of uids/gids, which in the vast
majority of installations would work just fine and wouldn't incur the
overhead of the mapping/unmapping operations.  There's no reason
uids/gids couldn't coexist with string names.  If the 4.0 spec had a
slightly different version of this paragraph:

   To provide a greater degree of compatibility with previous versions
   of NFS (i.e., v2 and v3), which identified users and groups by 32-bit
   unsigned uid's and gid's, owner and group strings that consist of
   decimal numeric values with no leading zeros can be given a special
   interpretation by clients and servers which choose to provide such
   support.  The receiver may treat such a user or group string as
   representing the same user as would be represented by a v2/v3 uid or
   gid having the corresponding numeric value.  A server is not
   obligated to accept such a string, but may return an NFS4ERR_BADOWNER
   instead.  To avoid this mechanism being used to subvert user and
   group translation, so that a client might pass all of the owners and
   groups in numeric form, a server SHOULD return an NFS4ERR_BADOWNER
   error when there is a valid translation for the user or owner
   designated in this way.  In that case, the client must use the
   appropriate name@domain string and not the special form for
   compatibility.

i.e., take out the "subvert" portion, and just plain allow string
representations of uids/gids, then at least the conversion would just be
an atoi and itoa.  Even better, allow the uids/gids to be used directly
and avoid the atoi/itoa, perhaps with a flag.  Either case is better
than idmapd and getting EDELAY and an X-second pause in odd places
because NFS has to go to userspace for a translation.

  -Dan Quixote

> -----Original Message-----
> From: Simon Kirby [mailto:sim@hostway.ca] 
> Sent: Thursday, September 03, 2009 1:06 PM
> To: Trond Myklebust
> Cc: Yohan; Andrew Morton; linux-kernel@vger.kernel.org; 
> linux-nfs@vger.kernel.org; Neil Brown; J. Bruce Fields; 
> mikevs@xs4all.net
> Subject: Re: VM issue causing high CPU loads
> 
> On Thu, Sep 03, 2009 at 10:02:06AM -0400, Trond Myklebust wrote:
> 
> > OK, so 16 hash buckets are likely to be filled with ~10^6 
> entries each.
> > I can see that might be a performance issue...
> 
> We have a similar setup with millions of UIDs over NFS 
> (currently NFSv3).
> I _wish_ there were a way to use NFSv4 without having to use 
> name-mapped UIDs and GIDs, since our user and group names 
> come from MySQL anyway, and are guaranteed to be consistent 
> across machines.
> 
> Why on earth does NFSv4 force the use of names?
> 
> I was considering hacking the code to stick IDs in there 
> anyway, but I haven't looked at the feasibility of this.  I 
> suspect this would break or complicate other things, but the 
> current NFSv4 design just seems like an incredible waste for 
> this case.
> 
> Simon-
> --
> To unsubscribe from this list: send the line "unsubscribe 
> linux-nfs" in the body of a message to 
> majordomo@vger.kernel.org More majordomo info at  
> http://vger.kernel.org/majordomo-info.html
> 
