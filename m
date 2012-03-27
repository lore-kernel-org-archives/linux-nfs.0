Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56368 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753634Ab2C0PG6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Mar 2012 11:06:58 -0400
Date: Tue, 27 Mar 2012 11:06:57 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v10 0/8] nfsd: overhaul the client name tracking code
Message-ID: <20120327150656.GB32055@fieldses.org>
References: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
 <20120323170630.GB6089@fieldses.org>
 <20120323132618.60e7e28d@corrin.poochiereds.net>
 <20120326200212.GD26254@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120326200212.GD26254@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 26, 2012 at 04:02:12PM -0400, J. Bruce Fields wrote:
> Having looked at it longer: first, I can't see how 4.1/krb5 callbacks
> ever really worked.  That's a project for another day.  (Soon, but
> probably not for 3.4.)

Bah, I'm stupid, I'd forgotten how 4.1 backchannel security works: the
client chooses which flavor(s) are acceptable in create_session (or the
mandatory but unimplemented backchannel_ct).  The Linux client always
chooses auth_sys.  We've never really paid much attention to the client.
Before we basically just used auth_sys no matter what.  Now we're using
krb5 in the krb5 case.  Both are wrong, but the latter also breaks in
practice against the Linux client.

I think I changed the behavior accidentally while overhauling the 4.1
server's callback and trunking behavior, probably with 80fc015bdfe
"nfsd4: use common rpc_cred for all callbacks".

I'll look into doing this a little more correctly....

--b.
