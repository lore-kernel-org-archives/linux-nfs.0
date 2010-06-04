From: Andy Adamson <andros@netapp.com>
Subject: Re: pnfs server data server list
Date: Fri, 4 Jun 2010 12:41:40 -0400
Message-ID: <2AA3D9BD-3C91-4662-80E6-DE08F65AB37B@netapp.com>
References: <20100604162559.GE10153@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "William A.(Andy) Adamson" <andros@citi.umich.edu>,
	linux-nfs@vger.kernel.org, eanderle@umich.edu
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16106 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753745Ab0FDQlm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jun 2010 12:41:42 -0400
In-Reply-To: <20100604162559.GE10153@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 4, 2010, at 12:25 PM, J. Bruce Fields wrote:

> We were just noticing that the pnfs/gfs2 code stores the data server
> list as a comma-delimited string of ip addresses.
>
> That string is passed from userspace without any validation--as far  
> as I
> can tell, if the adminstrator passes in random data, that random data
> will get handed to the client as is.

Yes, the validation code was never written.

>
> It would be better to validate that data when it's written to the
> /proc/fs/nfsd/ file--if for no other reason than to give  
> administrators
> better error messages.

Yes, that is where validation should occur, in  
nfsd4_set_pnfs_dlm_device.

>
> While we're at it: should we just store the thing as a list of
> sockaddr's instead of as a string?
>
> I figure that would:
> 	- guarantee we never forget to validate the input; and
> 	- be more useful if we eventually use them as addresses in the
> 	  kernel (e.g. for MDS<->DS protocol; does anyone have a
> 	  prototype design for that?).
>
> But it means some more work converting back and forth (since
> getdeviceinfo still needs the addresses as strings).

If validation occurs in nfsd4_set_pnfs_dlm_device then it is  
guaranteed that we never forget to validate the input. As for the  
sockaddr form being more useful for the yet-to-be designed (much less  
written) MDS<->DS protocol, don't bother until needed!

I vote for validation in nfsd4_set_pnfs_dlm_device and leaving it a  
comma-delimited string.

-->Andy

>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

