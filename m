Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.SerNet.de ([193.175.80.2]:39012 "EHLO mail.SerNet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753033Ab0GWJWN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Jul 2010 05:22:13 -0400
Date: Fri, 23 Jul 2010 11:14:53 +0200
From: =?iso-8859-1?Q?Bj=F6rn?= Jacke <bj@SerNet.DE>
To: "Ted Ts'o" <tytso@mit.edu>, tridge@samba.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jeremy Allison <jra@samba.org>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, Volker.Lendecke@SerNet.DE,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        Jan Engelhardt <jengelh@medozas.de>,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended file stats available [ver #6]
References: <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
 <30448.1279800887@redhat.com>
 <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
 <AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
 <E1Obxpd-00CRIo-SF@intern.SerNet.DE>
 <AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>
 <20100722162712.GB10352@jeremy-laptop>
 <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
 <19528.60019.28495.655512@samba.org>
 <20100723012130.GD16373@thunk.org>
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20100723012130.GD16373@thunk.org>
Message-Id: <E1OcEL8-00DP7W-V3@intern.SerNet.DE>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-07-22 at 21:21 -0400 Ted Ts'o sent off:
> Well, not POSIX, because POSIX doesn't have CreationTime at all.
> BSD's birthtime doesn't allow it to be set, and the question here is
> largely philosophical.

actually, it can (partly :). But the way it can be done is an insane hack:

<quote "http://ace.delos.com/kirk/">
To provide a sensible birth time for applications that are unaware of the birth
time attribute, we changed the semantics of the "utimes" system call so that if
the birth time was newer than the value of the modification time that it was
setting, it sets the birth time to the same time as the modification time. An
application that is aware of the birth time attribute can set both the birth
time and the modification time by doing two calls to "utimes". First it calls
"utimes" with a modification time equal to the saved birth time, then it calls
"utimes" a second time with a modification time equal to the (presumably newer)
saved modification time.
</quote>

Thus it can also be only be set more in the past.

Cheers
Björn
-- 
SerNet GmbH, Bahnhofsallee 1b, 37081 Göttingen
phone: +49-551-370000-0, fax: +49-551-370000-9
AG Göttingen, HRB 2816, GF: Dr. Johannes Loxen
