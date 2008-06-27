From: "Oeltze, Benjamin" <Benjamin.Oeltze-/ixSogHR0HOS/tZ4Wjpou0EOCMrvLtNR@public.gmane.org>
Subject: RE: Sm-notify
Date: Fri, 27 Jun 2008 08:58:13 +0200
Message-ID: <FC3FA7C4E1CA2348B5579A68B24556E9DA4AD413AB@ABGEX72E.FSC.NET>
References: <485A6033.3090301@citi.umich.edu>
    <20080625193757.GF12629@fieldses.org>
    <FC3FA7C4E1CA2348B5579A68B24556E9DA4AF2946C@ABGEX72E.FSC.NET>
 <46260.192.168.1.70.1214533375.squirrel@neil.brown.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: NeilBrown <neilb@suse.de>,
	"Laurenz, Dirk" <Dirk.Laurenz-/ixSogHR0HOS/tZ4Wjpou0EOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dgate20.fujitsu-siemens.com ([80.70.172.51]:18846 "EHLO
	dgate20.fujitsu-siemens.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751662AbYF0HII convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Jun 2008 03:08:08 -0400
In-Reply-To: <46260.192.168.1.70.1214533375.squirrel-eq65iwfR9nKIECXXMXunQA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
maybe I can specify Dirks question.

We are trying to set up a NFS Cluster and want to use sm-notify to info=
rm the Clients if the Server has failed over.
We have found a Howto that says: sm-notify uses files under /var/lib/nf=
s/sm to determine the Clients it has to inform.
Our Problem is, that ther are no files in this place even if we connet =
with a client. Is there anything we have forgotten?

Mit freundlichen Gr=FC=DFen
Benjamin Oeltze
Systems Engineer
DE ISC SOP PS N/O
=46ujitsu Siemens Computers
Hildesheimer Str. 25
30880 Laatzen
Telephone:      0511-8489 1872
Mobile: 0160-96354617
Email:  mailto: benjamin.oeltze-/ixSogHR0HOS/tZ4Wjpou0EOCMrvLtNR@public.gmane.org
Internet:       http://www.fujitsu-siemens.com
=46irmenangaben: http://www.fujitsu-siemens.de/imprint.html

-----Original Message-----
=46rom: NeilBrown [mailto:neilb@suse.de]
Sent: Friday, June 27, 2008 4:23 AM
To: Laurenz, Dirk
Cc: linux-nfs@vger.kernel.org; Oeltze, Benjamin
Subject: Re: Sm-notify

On Fri, June 27, 2008 3:59 am, Laurenz, Dirk wrote:
> Hi,
>
> Does anybody know how sm-notify exactly works on a suse sles 9 system=
?
>

Yes.

Do you have a specific question about it?

NeilBrown

