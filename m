Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11307 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751245Ab0HDSa0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 14:30:26 -0400
Subject: Re: numeric UIDs
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <0969EC03-E225-4265-BADC-582F2089D13E@u.washington.edu>
Date: Wed, 4 Aug 2010 14:30:05 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <C2AFF31B-A4A4-432C-A152-B28676B8C3A4@netapp.com>
References: <201008030401.33552.dreck@vmsd.ath.cx> <20100803164318.GB13896@merit.edu> <20100803192216.GC31579@fieldses.org> <DE966DA98A4ABE438D726BDF1699CF61403FAF9D@MX05A.corp.emc.com> <20100803215704.GA15494@merit.edu> <1280873719.14520.17.camel@heimdal.trondhjem.org> <20100803222337.GA9752@fieldses.org> <1280874675.14520.23.camel@heimdal.trondhjem.org> <20100803224245.GB9752@fieldses.org> <1280887336.24669.23.camel@heimdal.trondhjem.org> <0969EC03-E225-4265-BADC-582F2089D13E@u.washington.edu>
To: David Brodbeck <brodbd@u.washington.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 4, 2010, at 1:06 PM, David Brodbeck wrote:

> 
> On Aug 3, 2010, at 7:02 PM, Trond Myklebust wrote:
> 
>> On Tue, 2010-08-03 at 18:42 -0400, J. Bruce Fields wrote:
>>> On Tue, Aug 03, 2010 at 06:31:15PM -0400, Trond Myklebust wrote:
>>>> On Tue, 2010-08-03 at 18:23 -0400, J. Bruce Fields wrote:
>>>>> On Tue, Aug 03, 2010 at 06:15:19PM -0400, Trond Myklebust wrote:
>>> 
>>>> 2) Why is AUTH_SYS so sacrosanct?
>>> 
>>> Because it's what almost everyone uses.
>> 
>> No. It's the _default_. ...and a really really bad default.
> 
> The problem is the only supported alternative is to set up Kerberos.  This is a lot of work, especially for established sites where it essentially requires every user to change their password during the migration.  It also creates problems with ticket expiration if you have daemons or batch jobs that need continuous access to NFS filesystems.

Changing passwords is a good thing - should be done on a regular basis anyway. Ticket expiration is handled by using a keytab and a cron job to refresh the keytab.  That said, Kerberos does need to be easier (automatic) to set up than it is.

-->Andy

> 
> I've been looking at it for a while, because the 16-group limit is a problem for us, but it's a huge ball of wax.  I understand the security benefits, but the sheer complexity of setting it up and then coming up with workarounds for ticket expiration has me a bit cowed.
> 
> -- 
> 
> David Brodbeck
> System Administrator, Linguistics
> University of Washington
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

