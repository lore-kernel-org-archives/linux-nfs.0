Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:37796 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052Ab2DTUdd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Apr 2012 16:33:33 -0400
Date: Fri, 20 Apr 2012 16:33:27 -0400
From: Jim Rees <rees@umich.edu>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS4: fix referrals with IPv6 mounts
Message-ID: <20120420203327.GA16736@umich.edu>
References: <1334949705-33393-1-git-send-email-dros@netapp.com>
 <20120420194504.GA10259@umich.edu>
 <EA178ED0-5813-4235-A0CF-CF9D54AFB04F@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <EA178ED0-5813-4235-A0CF-CF9D54AFB04F@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adamson, Dros wrote:

  Who the hell thought it was a good idea for IPv6 to use ':' as a
  delimiter!?  Is it paranoid to think they designed it that way to make our
  lives harder? ;)

I remember commenting on this at an IETF in, like, 1992.  Even back then
before the web ":" was often used to separate IP address from port.  The
response, as I recall, was that we'd never use numeric addresses at the
application level, only domain names.
