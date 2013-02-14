Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46249 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934980Ab3BNVrr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Feb 2013 16:47:47 -0500
Date: Thu, 14 Feb 2013 16:47:44 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anand Avati <anand.avati@gmail.com>
Cc: "Theodore Ts'o" <tytso@mit.edu>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>, sandeen@redhat.com,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        gluster-devel@nongnu.org
Subject: Re: [Gluster-devel] regressions due to 64-bit ext4 directory cookies
Message-ID: <20130214214744.GC8343@fieldses.org>
References: <20130213153654.GC17431@thunk.org>
 <20130213162059.GL14195@fieldses.org>
 <CAFboF2wXvP+vttiff8iRE9rAgvV8UWGbFprgVp8p7kE43TU=PA@mail.gmail.com>
 <20130213222052.GD5938@thunk.org>
 <20130213224141.GU14195@fieldses.org>
 <20130213224720.GE5938@thunk.org>
 <CAFboF2z1akN_edrY_fT915xfehfHGioA2M=PSHv0Fp3rD-5v5A@mail.gmail.com>
 <20130213230511.GW14195@fieldses.org>
 <20130213234430.GF5938@thunk.org>
 <CAFboF2zS+YAa0uUxMFUAbqgPh3Kb4xZu40WUjLyGn8qPoP+Oyw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAFboF2zS+YAa0uUxMFUAbqgPh3Kb4xZu40WUjLyGn8qPoP+Oyw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 13, 2013 at 04:05:01PM -0800, Anand Avati wrote:
> On Wed, Feb 13, 2013 at 3:44 PM, Theodore Ts'o <tytso@mit.edu> wrote:
> >
> > I suspect this would seriously screw over Gluster, though, and this
> > wouldn't be a solution for NFSv3, since NFS needs long-lived directory
> > cookies, and not the short-lived cookies which is all POSIX/SuSv3
> > guarantees.
> >
> 
> Actually this would work just fine with Gluster. Except in the case of
> gluster-NFS, the native client is only acting like a router/proxy of
> syscalls to the backend system. A directory opened by an application will
> have a matching directory fd opened on ext4, and readdir from an app will
> be translated into readdir on the matching fd on ext4. So the
> app-on-glusterfs and glusterfsd-on-ext4 are essentially "moving in tandem".
> As long as the offs^H^H^H^H cookies do not overflow in the transformation,
> Gluster would not have a problem.
> 
> However Gluster-NFS (and NFS in general, too) will break, as we
> opendir/closedir potentially on every request.

Yes.  And, of course, NFS cookies live forever--we have no idea when a
client will hand one back to us and expect us to do something with it.

--b.
