From: Jeff Layton <jlayton@redhat.com>
Subject: Re: nfs-utils-1.2.0: insecure option and port range checking.
Date: Tue, 13 Oct 2009 14:07:38 -0400
Message-ID: <20091013140738.4a43592b@tlielax.poochiereds.net>
References: <ADD0E404-49A2-49AA-A3A1-A7065243E14E@openrbg.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Robert Gordon <rbg-dkEPNP4dzOJBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53139 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751294AbZJMSII (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Oct 2009 14:08:08 -0400
In-Reply-To: <ADD0E404-49A2-49AA-A3A1-A7065243E14E-dkEPNP4dzOJBDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 13 Oct 2009 12:56:29 -0500
Robert Gordon <rbg-dkEPNP4dzOJBDgjK7y7TUQ@public.gmane.org> wrote:

> 
> I noticed that the insecure option validates that the client port is a  
> subset of IPPORT_RESERVED as opposed to just validating it is a valid  
> reserved port. The following proposed patch would correct that issue.  
> Would anyone care to comment ? ..
> 
> # diff utils/mountd/auth.c utils/mountd/auth.c.orig
> 171a172
>  > 		    (ntohs(caller->sin_port) <  IPPORT_RESERVED/2 ||
> 

Ack on the idea, but you should probably send that patch as a unified
diff...

The only thing I can figure is that someone wanted to verify that the
call came from the ephemeral port range. But that's somewhat of a
nebulous concept when you mix in clients from other OS's...

I don't see any reason why we'd care that the calling port is "too"
low.

-- 
Jeff Layton <jlayton@redhat.com>
