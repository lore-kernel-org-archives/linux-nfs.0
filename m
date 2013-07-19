Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42353 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751762Ab3GSQNP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Jul 2013 12:13:15 -0400
Date: Fri, 19 Jul 2013 12:13:13 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Andre Heider <a.heider@gmail.com>, Rick Macklem <rmacklem@uoguelph.ca>,
        linux-nfs@vger.kernel.org
Subject: Re: Error writing to nfs4 with 3.11-rc1
Message-ID: <20130719161313.GA20026@fieldses.org>
References: <CAHsu+b_hhSr2vwcwM8TX3=xF=3HffUXG=YLVLcsEpH1wHn+JoA@mail.gmail.com>
 <A5C56FD6-9E14-43A3-8627-1C8F77EC6926@oracle.com>
 <CAHsu+b9vWUyCGHSs==Na=VntwvYp65=rva7+y9aQDXquxX4t-A@mail.gmail.com>
 <F3EFA483-0662-4226-AAF3-DCF12D48485E@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F3EFA483-0662-4226-AAF3-DCF12D48485E@oracle.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 17, 2013 at 04:54:59PM -0400, Chuck Lever wrote:
> By the way, the NFSv4 OPEN request parsing in Wireshark 1.10.0 is totally screwed up.  Has anyone reported this to the Wireshark community?  Wireshark 1.8.8 appears to parse OPEN requests correctly, and is able to handle the 3-word bitmask correctly.

What exactly is screwed up?

For what it's worth, I took a quick look at the 3.11 trace with the
latest head from http://code.wireshark.org/git/wireshark and nothing
jumped out at me.

--b.
