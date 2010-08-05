Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56701 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758080Ab0HESxj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Aug 2010 14:53:39 -0400
Date: Thu, 5 Aug 2010 14:52:12 -0400
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Cc: linux-nfs@vger.kernel.org
Subject: Re: ACLs
Message-ID: <20100805185211.GA11646@fieldses.org>
References: <20100805124729.GD31049@ics.muni.cz>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100805124729.GD31049@ics.muni.cz>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 05, 2010 at 02:47:29PM +0200, Lukas Hejtmanek wrote:
> Hello,
> 
> I use nfs4-acl-tools-0.3.3 and I get some oddities when setting the ACL:
> 
> $ nfs4_getfacl test
> A::OWNER@:rwatTcCy
> A::xhejtman@META:rtcy
> A::GROUP@:tcy
> A::EVERYONE@:tcy
> $ nfs4_setfacl -s "A::ludek@META:R" test
> $ nfs4_getfacl test
> D::OWNER@:r
> A::OWNER@:tTcCy
> A::ludek@META:rtcy
> A::GROUP@:tcy
> A::EVERYONE@:tcy
> 
> is this something expected or buggy acl-tools?

NFSv4 ACLs deny by default.  Thus the ACL "A::ludek@META:R" denies
permission to everyone else--including the owner of the file, if the
owner is not ludek.

The linux server has no way to store in its filesystem an acl that says
that; it *always* checks permissions for the owner before checking any
user permissions.

So the server decides it's safer to be pessimistic and adds that first
DENY....

Arguably the server could be less paranoid here.  But we'll always have
oddities like this as long as it doesn't have NFSv4 ACLs to work with on
the exported filesystem.  (Somebody's working on that.)

Workaround for now is probably just to always set the OWNER permissions
to be at least as permisive as anyone else's.  Or just add the
"A::ludek@META:R" ace instead of replacing the ACL wholesale (which is
what "-s" does).

(And then you'll still get ONWER, GROUP, and EVERYONE ACEs added on, but
they won't be as silly.)

--b.
