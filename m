Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:41573 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750695Ab0CAIJo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Mar 2010 03:09:44 -0500
Date: Mon, 1 Mar 2010 19:09:30 +1100 (EST)
From: James Morris <jmorris@namei.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
cc: Casey Schaufler <casey@schaufler-ca.com>,
        Stephen Smalley <sds@tycho.nsa.gov>, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Dave Quigley <dpquigl@tycho.nsa.gov>,
        "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/5] NFSv3: Add server namespace support for XATTR protocol
 implementation
In-Reply-To: <1267406263.3338.20.camel@localhost.localdomain>
Message-ID: <alpine.LRH.2.00.1003011900070.22072@tundra.namei.org>
References: <alpine.LRH.2.00.1002261457420.25193@tundra.namei.org>  <alpine.LRH.2.00.1002261537020.25193@tundra.namei.org>  <1267191990.7691.37.camel@moss-pluto.epoch.ncsc.mil>  <4B8B0F0B.4080603@schaufler-ca.com>
 <1267406263.3338.20.camel@localhost.localdomain>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 28 Feb 2010, Trond Myklebust wrote:

> The intention of the 'nfsd' namespace was to separate the local and
> remote xattr/security realms entirely. That includes allowing the server
> to set up separate policies to determine who is allowed to change those
> in the 'nfsd.*' namespace vs those who can change the ordinary
> 'security', 'trusted' and 'user' namespaces.

Ok -- this definitely sounds like a better approach.  I'll post an updated 
version soon.


- James
-- 
James Morris
<jmorris@namei.org>
