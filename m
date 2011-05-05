Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nm3-vm0.bullet.mail.sp2.yahoo.com ([98.139.90.230]:31209 "HELO
	nm3-vm0.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754276Ab1EEOQE convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 May 2011 10:16:04 -0400
Message-ID: <591857.64709.qm@web111726.mail.gq1.yahoo.com>
References: <781436.95809.qm@web111709.mail.gq1.yahoo.com> <OF40F1C0BA.A5FC46BA-ON85257887.004DC668-85257887.004DD321@us.ibm.com>
Date: Thu, 5 May 2011 07:16:03 -0700 (PDT)
From: Mahmood Naderan <nt_mahmood@yahoo.com>
Reply-To: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: Re: debugging nfs
To: Brian R Cowan <brcowan@us.ibm.com>
Cc: nfs <linux-nfs@vger.kernel.org>
In-Reply-To: <OF40F1C0BA.A5FC46BA-ON85257887.004DC668-85257887.004DD321@us.ibm.com>
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Well, I found the problem very nasty and in my previous posts, I mentioned some of them.
 
The big problem:
when the clients boots, it doesn't automatically mount the shared folders via /etc/fstab.
However after login to client, I can mount the folder manually with
 
"sudo mount -t nfs server:/opt /opt"
 
I really don't know why fstab doesn't work. I searched a lot.... some say disbale IPV6.
I did that but still have that problem.
 
So how can I tell nfs (on server or client) to be verbose so that I can see what is going on
and what is not going on.
 
Any feedback and comment is welcomed.

// Naderan *Mahmood;

From: Brian R Cowan <brcowan@us.ibm.com>
To: Mahmood Naderan <nt_mahmood@yahoo.com>
Cc: nfs <linux-nfs@vger.kernel.org>; linux-nfs-owner@vger.kernel.org
Sent: Thursday, May 5, 2011 6:40 PM
Subject: Re: debugging nfs


It would probably help to explain the problem
so you can get targeted debugging assistance... 

=================================================================
Brian Cowan
Advisory Software Engineer
ClearCase Software Advisory Team (SWAT)
Rational Software
IBM Software Group
550 King St
Littleton, MA 01460

Phone: 1.978.899.9471
Web: http://www.ibm.com/software/rational/support/




From:      
 Mahmood Naderan <nt_mahmood@yahoo.com> 
To:      
 nfs <linux-nfs@vger.kernel.org>,  
Date:      
 05/05/2011 09:30 AM 
Subject:    
   debugging nfs 
Sent by:    
   linux-nfs-owner@vger.kernel.org 



Hi,
I didn't find a method for debugging NFS for debain based systems. Is there 
any verbose switch or debuging method for that?

// Naderan *Mahmood;
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs"
in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html 
