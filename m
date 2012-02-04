Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gemsbok.le.ac.uk ([143.210.16.37]:57462 "EHLO gemsbok.le.ac.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751944Ab2BDVUf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 4 Feb 2012 16:20:35 -0500
Received: from 87-194-172-193.bethere.co.uk ([87.194.172.193]:49505 helo=[192.168.1.3])
	by gemsbok.le.ac.uk with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <liam.gretton@leicester.ac.uk>)
	id 1RtmYv-0004Rs-50
	for linux-nfs@vger.kernel.org; Sat, 04 Feb 2012 20:50:21 +0000
Message-ID: <4F2D9A0E.6010503@leicester.ac.uk>
Date: Sat, 04 Feb 2012 20:50:22 +0000
From: Liam Gretton <liam.gretton@leicester.ac.uk>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: where can I ask user qns about nfs4?
References: <4F2A2F9E.6030908@steve-ss.com> <CAGue13owEdBsr+anLKrbW931QZHYC7RbwiSH_7WjBb5aXw4JJQ@mail.gmail.com>
In-Reply-To: <CAGue13owEdBsr+anLKrbW931QZHYC7RbwiSH_7WjBb5aXw4JJQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a related question, and like the OP I was reluctant to ask here 
as it's not a dev question, but I can't find any other suitable forum.

Has ANYBODY got kerberised NFS working where the KDC is Active Directory 
on a Windows 2008 R2 system? With 2008 R2, DES encryption for Kerberos 
is no longer enabled.

Our AD admins are understandably not keen to go against the recommended 
behaviour and enable DES just for this service (it needs to be enabled 
globally across the domain).

I can't find any documentation about Kerberised NFS that looks more 
recent than about 2006. That coupled with what I can see in the sources 
suggest that there's little development in this area, so I suspect the 
answer is that nobody has managed what I'm trying to do.

-- 
Liam Gretton                                    liam.gretton@le.ac.uk
HPC Architect                                http://www.le.ac.uk/its/
IT Services                                   Tel: +44 (0)116 2522254
University Of Leicester, University Road
Leicestershire LE1 7RH, United Kingdom
