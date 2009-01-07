From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 6 Jan 2009 19:26:08 -0500
Message-ID: <20090107002608.GK13785@fieldses.org>
References: <20090106011314.534653345@us.ibm.com> <20090106011314.961946803@us.ibm.com> <20090106200229.GA17031@us.ibm.com> <1231274682.20316.65.camel@heimdal.trondhjem.org> <20090106215831.GE18147@us.ibm.com> <m1eizg11fy.fsf@frodo.ebiederm.org> <1231283734.8041.6.camel@heimdal.trondhjem.org> <20090106233238.GD13785@fieldses.org> <1231284943.8041.8.camel@heimdal.trondhjem.org> <1231287607.11487.0.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Linux Containers <containers@lists.linux-foundation.org>,
	linux-nfs@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:32843 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751006AbZAGA0R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2009 19:26:17 -0500
In-Reply-To: <1231287607.11487.0.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 06, 2009 at 07:20:07PM -0500, Trond Myklebust wrote:
> As for the NFSv4 clientid, I can't see how you would ever want to use
> anything other than the init->utsname(), since the requirement is only
> that the clientid string be unique and preserved across reboots. The
> server isn't allowed to interpret the contents of the clientid string.
> Ditto for the RPCSEC_GSS machine creds that are used to establish the
> clientid.

If people eventually expect to be able to, say, migrate a container to
another host while using an nfs mount as their storage, then they'd need
the name to be that of the container, not of the host.

Obviously we'd also need to ensure the container got its own nfsv4
client state, etc., etc., and it sounds like we're far from that.

--b.
