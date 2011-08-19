Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:57865 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751458Ab1HSBFs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Aug 2011 21:05:48 -0400
Date: Fri, 19 Aug 2011 11:05:36 +1000
From: NeilBrown <neilb@suse.de>
To: paul.szabo@sydney.edu.au
Cc: linux-nfs@vger.kernel.org
Subject: Re: Please support NSF squashing multiple groups
Message-ID: <20110819110536.1f0133c6@notabene.brown>
In-Reply-To: <201108190032.p7J0W3ZX030679@bari.maths.usyd.edu.au>
References: <201108190032.p7J0W3ZX030679@bari.maths.usyd.edu.au>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 19 Aug 2011 10:32:03 +1000 paul.szabo@sydney.edu.au wrote:

> Dear Linux-NFS people,
> 
> NFS has always had the root_squash option, to protect against a remote
> and possibly evil root. NFS should also protect all privileged, or at
> least all root-equivalent, UIDs and GIDs. Many UNIX distributions have
> root-equivalent GIDs, groups whose members could easily become root,
> some listed in http://bugs.debian.org/299007#219 .
> 
> Currently, NFS has no ways to protect privileged UIDs and GIDs other
> than root himself. Such options should be implemented, to make NFS
> safer and more useful. As I understand it, the hold-up is not within
> NFS code, but with kernel interfaces not supporting lists of squashed
> entities. I am asking you to devise and implement such interfaces.
> 
> References:
> http://bugs.debian.org/299007
> http://bugs.debian.org/384922
> http://bugs.debian.org/538392
> https://bugzilla.kernel.org/show_bug.cgi?id=14295
> 
> Thanks, Paul
> 
> Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
> School of Mathematics and Statistics   University of Sydney    Australia

Hi Paul,

 I would be much more inclined to go the other way and remove the root_squash
 option so that nothing is squashed.  It is not really a clever idea and
 doesn't really do anything useful - partly because as you note there are
 other uids that can be dangerous.

 If you are using kerberos authentication then you should be able to trust
 that any remote user really is who they say they are, and if you aren't then
 maybe you should be .... we really are running out of excuses to use
 kerberos and it is really quite easy (even I could set it up in half an
 hour!).

 If you are using NFSv4 and kerberos than there already exist interfaces to
 do what you want. See "man idmap.conf".  You can write a plugin that maps a
 textual user or group name to a numeric id number.  So you can squash
 anything that you want to squash, and squash it in any way that you like.

 Does that help?

NeilBrown

