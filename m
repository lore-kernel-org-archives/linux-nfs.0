Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52283 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757178Ab0LBXLI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Dec 2010 18:11:08 -0500
Subject: Re: NFSv4 behaviour on unknown users
Content-Type: text/plain; charset=us-ascii
From: Thomas Haynes <thomas@netapp.com>
In-Reply-To: <20101201162912.GC6832@fieldses.org>
Date: Thu, 2 Dec 2010 17:10:48 -0600
Cc: Spelic <spelic@shiftmail.org>, linux-nfs@vger.kernel.org
Message-Id: <99BBEF51-7EB1-4BAA-9B12-F0F98A629C74@netapp.com>
References: <4CF3F326.4060608@shiftmail.org> <20101129190122.GA31843@fieldses.org> <1291057747.12784.38.camel@heimdal.trondhjem.org> <4CF519F2.8080900@RedHat.com> <1291155578.2998.38.camel@heimdal.trondhjem.org> <20101130222651.GB5054@fieldses.org> <1291156414.4393.2.camel@heimdal.trondhjem.org> <20101130223627.GC5054@fieldses.org> <20101201135740.0d3b5948@notabene.brown> <1291173002.7694.7.camel@heimdal.trondhjem.org> <20101201162912.GC6832@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 1, 2010, at 10:29 AM, J. Bruce Fields wrote:

> On Tue, Nov 30, 2010 at 10:10:02PM -0500, Trond Myklebust wrote:
>> 
>> I think you need to take beepy's words in context here: as I believe I
>> mentioned previously, RFC3530 (and its predecessor RFC3010) assumed
>> everyone would be using principals for authenticating, either through
>> RPCSEC_GSS w/ krb5, or through the SPKM/Lipkey mechanism. So sure was
>> everyone of this, that AUTH_SYS isn't even mentioned as a valid
>> authentication mechanism, and so nobody had to worry about the
>> consequences of using it.
> 
> I also wonder whether the value of a transparent upgrade from NFSv3 got
> a little lost.
> 
> To me that seems like the first requirement for version n+1 of
> anything--that we should be able to upgrade people to version n without
> their noticing.
> 
> Maybe there are features that are necessarily incompatible, and that
> merit the downside, but the downside--losing the chance to get new
> features to every user automatically--seems significant to me.
> 
> 
> And, perhaps it's a disease, but I have gotten into the habit of
> thinking of the (krb5 principal)->(id, gid's) mapping as independent of
> the (NFSv4 user name)<->(uid) and (NFSv4 group name)<->(gid) mappings.
> 
> Granted they have to be coordinated on any reasonably complicated setup.
> But there are simple cases where they don't necessarily need to be.
> 
> E.g. on a dumb "cp -ax / /nfs" backup it doesn't really matter "who"
> does the backup as long as they have sufficient permissions, since the
> files will all be explicitly chown'd as they're created.  And with krb5
> it's simple enough to make that work with a single static mapping from a
> client-side principal to root on the server.
> 
> And, again, that's something that works now with NFSv3.
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Another question is whether or not such an approach would be appreciated
as part of 3530bis?

I.e., we don't have to change the over-the-wire protocol, but via a consistent
interpretation, all clients and servers can offer a smoother NFSv3 -> NFSv4.x
upgrade path.