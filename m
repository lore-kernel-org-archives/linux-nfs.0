From: Robert Gordon <rbg-dkEPNP4dzOJBDgjK7y7TUQ@public.gmane.org>
Subject: nfs-utils-1.2.0: insecure option and port range checking.
Date: Tue, 13 Oct 2009 12:56:29 -0500
Message-ID: <ADD0E404-49A2-49AA-A3A1-A7065243E14E@openrbg.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:49742 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933807AbZJMR6K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Oct 2009 13:58:10 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I noticed that the insecure option validates that the client port is a  
subset of IPPORT_RESERVED as opposed to just validating it is a valid  
reserved port. The following proposed patch would correct that issue.  
Would anyone care to comment ? ..

# diff utils/mountd/auth.c utils/mountd/auth.c.orig
171a172
 > 		    (ntohs(caller->sin_port) <  IPPORT_RESERVED/2 ||

--
Robert. 
