Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38574 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751992AbdFHPgu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Jun 2017 11:36:50 -0400
Date: Thu, 8 Jun 2017 11:36:49 -0400
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@RedHat.com>,
        Lennart Poettering <mzxreary@0pointer.de>,
        systemd-devel@freedesktop.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs.man: document incompatibility between "bg" option
 and systemd.
Message-ID: <20170608153649.GB8625@fieldses.org>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name>
 <20170529133814.GC17967@gardel-login>
 <87tw43fgrf.fsf@notabene.neil.brown.name>
 <89415cad-331e-bac6-7fd1-dffa058726de@RedHat.com>
 <87lgp4dbx7.fsf@notabene.neil.brown.name>
 <2a7fd6d4-a965-02e0-3b7b-97c5743d7083@RedHat.com>
 <20170607120221.GJ27006@gardel-login>
 <ce5c37b4-a81b-4eaf-c1ac-7f36488bdaa9@RedHat.com>
 <87mv9jawjf.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87mv9jawjf.fsf@notabene.neil.brown.name>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 08, 2017 at 03:16:52PM +1000, NeilBrown wrote:
> So I think I've found a solution for systemd to handle "bg" nfs mounts
> correctly.   I'll submit some pull requests for consideration.

Out of curiosity, after that change is there still any reason you'd
recommend any new user actually use "bg" (as opposed to an automount)?

I appreciate the effort to keep existing systems working, I'm just
curious.

--b.
