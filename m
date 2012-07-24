Return-Path: linux-nfs-owner@vger.kernel.org
Received: from caiajhbdccac.dreamhost.com ([208.97.132.202]:46501 "EHLO
	homiemail-a77.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755888Ab2GXU3I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2012 16:29:08 -0400
Received: from homiemail-a77.g.dreamhost.com (localhost [127.0.0.1])
	by homiemail-a77.g.dreamhost.com (Postfix) with ESMTP id 789969406D
	for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2012 13:29:08 -0700 (PDT)
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: nico@cryptonector.com)
	by homiemail-a77.g.dreamhost.com (Postfix) with ESMTPSA id 4DD5394065
	for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2012 13:29:08 -0700 (PDT)
Received: by pbbrp8 with SMTP id rp8so136750pbb.19
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2012 13:29:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120724200932.GM8570@fieldses.org>
References: <20120724193348.GA4977@netapp.com>
	<CAK3OfOji009CP88tDNOp-nvdPBkvp0oKfJUqhO_TYuZktwhUCg@mail.gmail.com>
	<20120724200932.GM8570@fieldses.org>
Date: Tue, 24 Jul 2012 15:29:07 -0500
Message-ID: <CAK3OfOiKYJjmDEsOOFqg3wD8pwBir4B4CpOTF1Ab3jdHhJTKwA@mail.gmail.com>
Subject: Re: [nfsv4] Constructing a NFSv4 ACL from POSIX mode bits
From: Nico Williams <nico@cryptonector.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Haynes, Tom" <thomas@netapp.com>, linux-nfs@vger.kernel.org,
        nfsv4@ietf.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 24, 2012 at 3:09 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> But Tom was asking above only about ACE4_WRITE_ACL.  And possibly only
> in the legacy case.  (Does ZFS have a real ACE4_WRITE_ACL bit?)

Ah, oops.  That's trickier.  The examples don't say (or I'm not seeing
it).  IMO the most reasonable thing to do is to make chmod mask away
the ACE4_WRITE_ACL bits of non-OWNER@/non-owner-user ACEs, but
subsequent ACL writes can restore ACE4_WRITE_ACL without contributing
to the w group or world bits of mode.

That is: to make aclmode=mask most natural and usable a chmod must
have the expected POSIX behavior of taking away or granting access,
but never granting anything like ACE4_WRITE_ACL to non-owners, while
an ACL write should should be able to grant much more access than
chmod and it should compute a new mode that is as close as possible to
the new ACL.  This requires storing a mode, an ACL, and one bit to
indicate whether the ACL was set after the mode or the mode after the
ACL.

Nico
--
