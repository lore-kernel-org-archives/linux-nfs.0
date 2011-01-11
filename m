Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46526 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932142Ab1AKVen (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jan 2011 16:34:43 -0500
Date: Tue, 11 Jan 2011 16:34:40 -0500
To: Edgar Almonte <samudhio@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS v4 shares, ID's setup
Message-ID: <20110111213440.GC28537@fieldses.org>
References: <AANLkTi=C-Ux0voD2SVXTAMXzfjHmU3EYZmrashRjWuGo@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTi=C-Ux0voD2SVXTAMXzfjHmU3EYZmrashRjWuGo@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jan 07, 2011 at 06:57:38PM -0400, Edgar Almonte wrote:
> i am doing my first time nfs sharing at home , now i am using nfsv4
> for it and i want setup a public share
> so anybody that hook in the network can access the share ( with rw access )
> but look like that is not possible because as far i read you need have
> the user/group id un sync between client and server
> so i am looking for some confirmation of what i can get understand so
> far or/and clarification.

Usually people use something like nis or ldap as a common database for
user and group information.

(There are outstanding patches to allow the client to use numbers for
everything on the wire, if you turn on some module parameter.  We may
patch the server similarly.

But then you would need all your clients to be recent enough, and turn
on the necessary option on all of them and on the server.)

--b.
