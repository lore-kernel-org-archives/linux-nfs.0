Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46588 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755531Ab1HSTTt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Aug 2011 15:19:49 -0400
Date: Fri, 19 Aug 2011 15:19:45 -0400
To: paul.szabo@sydney.edu.au
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
Subject: Re: Please support NSF squashing multiple groups
Message-ID: <20110819191945.GA1641@fieldses.org>
References: <20110819110536.1f0133c6@notabene.brown>
 <201108190210.p7J2AYCB028893@bari.maths.usyd.edu.au>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201108190210.p7J2AYCB028893@bari.maths.usyd.edu.au>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 19, 2011 at 12:10:34PM +1000, paul.szabo@sydney.edu.au wrote:
> > If you are using kerberos authentication then you should be able
> > to trust that any remote user really is who they say they are ...
> 
> Does that "work" also against the "evil remote root" e.g. when the
> remote machine is compromised?

It does what's possible.  If a user gives their credentials to the
compromised client--well, what can you do, the attacker has their
credentials at that point.  So if everyone in your department logs into
the same client, then root on that client is going to be able to
impersonate any of them.  Nothing you can do about that.

On the other hand, if several people each have their own client and only
log in to their own clients, and if one of the clients is compromised,
then that client isn't going to be able to impersonate users that have
never given it any credentials.

> > If you are using NFSv4 and kerberos than there already exist
> > interfaces to do what you want. See "man idmap.conf". ...
> 
> Sorry I do not use NFSv4 or kerberos, yet. Could you please point me
> to references about idmap.conf, the ones I found suggest it only takes
> [Mapping] settings for Nobody-User and Nobody-Group.

Look for "static" in a recent version of the idmapd.conf man page.

--b.
