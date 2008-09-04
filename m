From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs and kerberos authentification problem.
Date: Thu, 4 Sep 2008 13:33:46 -0400
Message-ID: <20080904173346.GJ4536@fieldses.org>
References: <48BED539.1000404@skynet.be> <4d569c330809031312p3515f4d8id9cbec94d871e058@mail.gmail.com> <48C0108F.40204@skynet.be> <20080904165645.GG4536@fieldses.org> <48C01B5F.3060808@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Kevin Coffman <kwc@umich.edu>, linux-nfs@vger.kernel.org
To: =?utf-8?B?RnJhbsOnb2lz?= Valenduc <francois.valenduc@skynet.be>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:35113 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751590AbYIDRds (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2008 13:33:48 -0400
In-Reply-To: <48C01B5F.3060808@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 04, 2008 at 07:31:11PM +0200, Fran=C3=A7ois Valenduc wrote:
> I had indeed forgot to add sec=3Dkrb5 to the export options. But even=
 if I =20
> add it, it doesn't change anything.

OK, and you re-exported?  (Just to double-check--what does exportfs -v
say?)

> Is it really possible to use krb5  authentification with nfs ? I have
> read a lot of howto and follow the  instructions and it never
> succeeds...

I'm sorry you've had trouble with it, but yes, it definitely works--I
use it every day.

--b.
