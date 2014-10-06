Return-Path: linux-nfs-owner@vger.kernel.org
Received: from auth-4.ukservers.net ([217.10.138.158]:57609 "EHLO
	auth-4.ukservers.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441AbaJFOii (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Oct 2014 10:38:38 -0400
Date: Mon, 6 Oct 2014 15:38:32 +0100 (BST)
From: Carl Hetherington <cth@carlh.net>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
cc: linux-nfs@vger.kernel.org
In-Reply-To: <54329138.5020801@Netapp.com>
Message-ID: <alpine.DEB.2.02.1410061537220.27485@main.carlh.net>
References: <alpine.DEB.2.02.1410032137370.27485@main.carlh.net> <54329138.5020801@Netapp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Subject: Re: [PATCH] for intermittent erroneous uid/gid bug with
 NFS4/Kerberos
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Anna,

> I'm having some trouble getting this patch to apply.  What version of 
> the kernel did you develop it against?  You might also want to double 
> check your formatting to make sure tabs and spaces aren't changed.

It is against Ubuntu's "trusty" tree:
git://kernel.ubuntu.com/ubuntu/ubuntu-trusty.git

Let me know if I should rebase it against something else.

> Can you make this two separate patches?  One should be for the 
> request_valid_key_with_auxdata() implementation, and the other with NFS 
> changes.

I have just re-posted the patch split up into two.

Thank you for your time
Carl
