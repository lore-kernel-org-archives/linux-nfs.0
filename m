Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57126 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756562Ab3EVRiE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 May 2013 13:38:04 -0400
Date: Wed, 22 May 2013 13:38:02 -0400
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Announcing nfs-ordeal
Message-ID: <20130522173802.GA31069@fieldses.org>
References: <519BE3AB.1020104@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <519BE3AB.1020104@netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 21, 2013 at 05:14:19PM -0400, Bryan Schumaker wrote:
> Hi everybody!
> 
> I've pushed out my Jenkins work to git://git.linux-nfs.org/projects/bjschuma/nfs-ordeal.git under the new name "nfs-ordeal".  This git repo includes both the Jenkins xml jobs and various helper scripts that they call to do testing (you'll have to download Jenkins and some plugins on your own - see the install.sh script).  If you just want a tarball, you can find one at www.linux-nfs.org/~bjschuma/nfs-ordeal-v1.0.tar.gz.

A README would help:

	- directions above, pointer to install.sh
	- what it does
	- what else you need (test machines, bare-metal or otherwise?)

--b.
