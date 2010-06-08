From: Christopher Hawkins <chawkins-eCVT+wl/HiBBDgjK7y7TUQ@public.gmane.org>
Subject: Re: Returning error to app on TCP disconnect
Date: Tue, 08 Jun 2010 08:02:41 -0400 (EDT)
Message-ID: <488124.741275998561110.JavaMail.javamailuser@localhost>
References: <5462028.721275998477790.JavaMail.javamailuser@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Shehjar Tikoo <shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from vms173019pub.verizon.net ([206.46.173.19]:44164 "EHLO
	vms173019pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754720Ab0FHMKM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jun 2010 08:10:12 -0400
Received: from backoffice.bplinux.com ([unknown] [98.118.141.73])
 by vms173019.mailsrvcs.net
 (Sun Java(tm) System Messaging Server 7u2-7.02 32bit (built Apr 16 2009))
 with ESMTPA id <0L3P003S634L73C1-RPlcTzejgObX34wcKVtf5HL67TkHkek2@public.gmane.org> for
 linux-nfs@vger.kernel.org; Tue, 08 Jun 2010 07:10:01 -0500 (CDT)
In-reply-to: <5462028.721275998477790.JavaMail.javamailuser@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Shejar, what about the "soft" mount option on the client side, and possibly "intr"? Maybe I am misunderstanding your goal but it sounds like that is what you want. 

Chris  

----- "Shehjar Tikoo" <shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org> wrote:

> Hi all
> 
> I am working on a setup where when a nfsv3 server goes down, the dd
> that 
> is running on the NFS mount point, gets an error on any syscall 
> performed on that mount point, say a write () to a file on that
> mount.
> 
> I've tried setting the timeo and retrans options at mount but that
> does 
> not seem to work in this case. The how-to on linux-nfs site confirms 
> that the nfs client just waits for the server to come back up after 
> retrans number of requests.
> 
> Is there a way to have the app receive an EIO or any other error on
> TCP 
> disconnect?
> 
> Thanks
> -Shehjar
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
