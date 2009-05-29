From: Rob Gardner <rob.gardner@hp.com>
Subject: Re: Huge race in lockd for async lock requests?
Date: Thu, 28 May 2009 20:59:02 -0600
Message-ID: <4A1F4F76.70108@hp.com>
References: <4A0D80B6.4070101@redhat.com> <4A0D9D63.1090102@hp.com> <4A11657B.4070002@redhat.com> <4A1168E0.3090409@hp.com> <4A1319F9.90304@hp.com> <4A13A973.4050703@hp.com> <4a140d0a.85c2f10a.53bc.0979@mx.google.com> <4A1431B1.6080708@hp.com> <20090528200523.GE13860@fieldses.org> <4A1F035B.4040306@hp.com> <20090529002636.GA19184@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "tmtalpey@gmail.com" <tmtalpey@gmail.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:4658 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253AbZE2C7D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2009 22:59:03 -0400
In-Reply-To: <20090529002636.GA19184@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
>
> Looking at the code....  This is all under the BKL, and as far as I can
> tell there aren't any blocking operations anywhere there, so I don't
> think this should happen if the filesystem is careful.  Have you seen it
> happen?


Aha, I just figured it out and you were right. The filesystem in this 
case was not careful. It broke the rules and actually made the fl_grant 
call *before* even returning to nlmsvc_lock's call to vfs_lock_file, and 
it did it in the lockd thread! So the BKL was of no use, and I saw 
nlmsvc_grant_deferred print "grant for unknown block". So I think 
everything is ok, no huge race in lockd for async lock requests. Thank 
you for clearing this up.

Rob Gardner

