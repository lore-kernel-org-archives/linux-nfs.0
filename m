From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: redundant reverse DNS on NFS mount or umount
Date: Thu, 26 Feb 2009 11:00:43 -0500
Message-ID: <88ADDFBF-1A51-47B5-A812-8E416A1720ED@oracle.com>
References: <499AD63B.20806@draigBrady.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed	delsp=yes
Cc: linux-nfs@vger.kernel.org
To: =?ISO-8859-1?Q?P=E1draig_Brady?= <P@draigBrady.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:44318 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754381AbZBZQAx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Feb 2009 11:00:53 -0500
In-Reply-To: <499AD63B.20806-V8g9lnOeT5ydJdNcDFJN0w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 17, 2009, at Feb 17, 2009, 10:22 AM, P=E1draig Brady wrote:
> I've a problem where reverse DNS is being done by the NFS server.
> This is very problematic when the DNS server goes away.
> As far as I can see there should be no lookups being performed
> because I've nothing in /etc/hosts.{allow,deny} and just
> numeric hosts in /etc/exports.

rpc.statd performs reverse DNS lookups to verify the hostname of the =20
remote that is about to be monitored.... perhaps that is one place to =20
start looking.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com