Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:54996 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751229Ab3JWO7l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Oct 2013 10:59:41 -0400
Date: Wed, 23 Oct 2013 10:42:00 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] mountd: Deprecate the ability to disable TCP
 listeners.
Message-ID: <20131023144200.GA25132@umich.edu>
References: <1382429966-14531-1-git-send-email-steved@redhat.com>
 <1382429966-14531-3-git-send-email-steved@redhat.com>
 <20131022113940.GA15951@umich.edu>
 <5267D630.4030909@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5267D630.4030909@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson wrote:

  On 22/10/13 07:39, Jim Rees wrote:
  > Steve Dickson wrote:
  > 
  >   -"	[-N version|--no-nfs-version version] [-n|--no-tcp]\n"
  >   +"	[-N version|--no-nfs-version version] [-n|--no-tcp(deprecate)]\n"
  > 
  > I would take this out.
  > 
  Take out the word "deprecate" or the "[-n|--no-tcp(deprecate)]" flag?

Like this:

"	[-N version|--no-nfs-version version]\n"
