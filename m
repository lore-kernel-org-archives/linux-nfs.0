Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36174 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760143Ab2HXWCV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Aug 2012 18:02:21 -0400
Date: Fri, 24 Aug 2012 18:02:19 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Rick Macklem <rmacklem@uoguelph.ca>
Cc: linux-nfs@vger.kernel.org,
        Norbert Aschendorff <norbert.aschendorff@yahoo.de>,
        Trond Myklebust <trond@netapp.com>
Subject: Re: NFSv4, Name (string) mapping vs. raw UID, idmapd and Kernels
 >= 3.3
Message-ID: <20120824220219.GB21832@fieldses.org>
References: <20120823144605.GA6923@fieldses.org>
 <900847353.1046192.1345767936102.JavaMail.root@erie.cs.uoguelph.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <900847353.1046192.1345767936102.JavaMail.root@erie.cs.uoguelph.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 23, 2012 at 08:25:36PM -0400, Rick Macklem wrote:
> Then on the next page:
> 
>    To provide a greater degree of compatibility with previous versions
>    of NFS (i.e., v2 and v3), which identified users and groups by 32-bit
>    unsigned uid's and gid's, owner and group strings that consist of
>    decimal numeric values with no leading zeros can be given a special
>    interpretation by clients and servers which choose to provide such
>    support.  
>    ** The receiver may treat such a user or group string as
>    representing the same user as would be represented by a v2/v3 uid or
>    gid having the corresponding numeric value.  A server is not
>    obligated to accept such a string, but may return an NFS4ERR_BADOWNER
>    instead.  
>    --> To avoid this mechanism being used to subvert user and
>    group translation, so that a client might pass all of the owners and
>    groups in numeric form, a server SHOULD return an NFS4ERR_BADOWNER
>    error when there is a valid translation for the user or owner
>    designated in this way.  In that case, the client must use the
>    appropriate name@domain string and not the special form for
>    compatibility.
> 
> The sentence at "**" says a receiver "may" recognize the numeric uid/gid#
> string. This would suggest that a client isn't expected/required to do so,
> as I read it. (This page seems to be very confusing w.r.t. what clients/servers
> are expected/required to support.)
> The sentence at "-->" is a SHOULD (not a MUST, I admit) that seems to
> say a server should only allow numeric uid/gid# strings when there isn't
> a name<->uid/gid# translation and should avoid allowing clients to just
> use uid/gid# strings?

Yeah, I thought I remembered some stronger requirement on the client,
but the strongest I can get out of this is: "well, it says the server
MAY return numeric id's, so that effectively means the client MUST
handle them"... but that doesn't really require the client to do
anything in particular with them.

Cc'ing Trond in case he remember some language we overlooked.  Of course
3530bis is different:

	http://tools.ietf.org/html/draft-ietf-nfsv4-rfc3530bis-18#section-5.9

	"The client MUST always accept numeric values if the security
	mechanism is not RPCSEC_GSS."

> Anyhow, I do plan to re-enable support for numeric uid/gid# strings in
> the FreeBSD NFSv4 client, but it won't be released until 9.2 at the
> earliest. (I, personally, have no problem with numeric uid/gid# strings.
> I disabled support for them because I had thought the working group
> didn't want them supported.)

OK.  Yes it's been confusing!

--b.
