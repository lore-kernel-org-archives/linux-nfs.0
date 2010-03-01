Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14684 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751609Ab0CABgt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Feb 2010 20:36:49 -0500
Subject: Re: [PATCH 5/5] NFSv3: Add server namespace support for XATTR
 protocol implementation
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: Stephen Smalley <sds@tycho.nsa.gov>, James Morris <jmorris@namei.org>,
        linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Dave Quigley <dpquigl@tycho.nsa.gov>,
        "Serge E. Hallyn" <serue@us.ibm.com>
In-Reply-To: <4B8B0F0B.4080603@schaufler-ca.com>
References: <alpine.LRH.2.00.1002261457420.25193@tundra.namei.org>
	 <alpine.LRH.2.00.1002261537020.25193@tundra.namei.org>
	 <1267191990.7691.37.camel@moss-pluto.epoch.ncsc.mil>
	 <4B8B0F0B.4080603@schaufler-ca.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 28 Feb 2010 20:17:43 -0500
Message-ID: <1267406263.3338.20.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 2010-02-28 at 16:49 -0800, Casey Schaufler wrote:

> I'm mostly in agreement with Stephen. I wouldn't object to a separate
> "nfsd." namespace, as opposed to "security." or "trusted." because I
> think that in reality you're not going to get very far without treating
> is a special case in any event. May as well acknowledge it up front.

That was indeed what I envisioned when I suggested it to James
originally, but I may have been a bit unclear on the subject.

I don't think that either 'security' or 'trusted' are a good fit here,
since they both have special meanings to local applications on the
server. 'user' is just wrong, since that means that ordinary local users
may end up with the power to change the security settings for remote
applications.

The intention of the 'nfsd' namespace was to separate the local and
remote xattr/security realms entirely. That includes allowing the server
to set up separate policies to determine who is allowed to change those
in the 'nfsd.*' namespace vs those who can change the ordinary
'security', 'trusted' and 'user' namespaces.

Cheers
  Trond
