Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from idcmail-mo2no.shaw.ca ([64.59.134.9]:19849 "EHLO
	idcmail-mo2no.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754971Ab1EaTQf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 May 2011 15:16:35 -0400
Subject: Re: infinite getdents64 loop
Content-Type: text/plain; charset=us-ascii
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <4DE528DE.5020908@itwm.fraunhofer.de>
Date: Tue, 31 May 2011 13:16:34 -0600
Cc: "Ted Ts'o" <tytso@mit.edu>, linux-nfs@vger.kernel.org,
        "linux-ext4@vger.kernel.org List" <linux-ext4@vger.kernel.org>,
        Fan Yong <yong.fan@whamcloud.com>
Message-Id: <048ABCD7-FB3B-44CF-A0A5-4B230B1775DE@dilger.ca>
References: <201105281502.32719.sweet_f_a@gmx.de> <201105301137.02061.sweet_f_a@gmx.de> <1306767521.5971.2.camel@lade.trondhjem.org> <201105311147.24939.sweet_f_a@gmx.de> <4DE4C063.9060100@itwm.fraunhofer.de> <20110531123518.GB4215@thunk.org> <D598829B-FB36-4DA8-978E-8C689940D0FA@dilger.ca> <4DE528DE.5020908@itwm.fraunhofer.de>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-05-31, at 11:43 AM, Bernd Schubert wrote:
> On 05/31/2011 07:26 PM, Andreas Dilger wrote:
>> If it's of interest, we've implemented a 64-bit hash mode for ext4 to
>> solve just this problem for Lustre.  The llseek() code will return a
>> 64-bit hash value on 64-bit systems, unless it is running for some
>> process that needs a 32-bit hash value (only NFSv2, AFAIK).
>> 
>> The attached patch can at least form the basis for being able to return
>> 64-bit hash values for userspace/NFSv3/v4 when usable.  The patch
>> is NOT usable as it stands now, since I've had to modify it from the
>> version that we are currently using for Lustre (this version hasn't
>> actually been compiled), but it at least shows the outline of what needs
>> to be done to get this working.  None of the NFS side is implemented.
> 
> Thanks Andreas! I haven't tested it yet, but the generic idea looks good. I guess the lower part of the patch (netfilter stuff) got accidentally in?

Oops, I had refreshed the patch just before sending, and forgot to remove those parts.  They are definitely not relevant to this issue.

Cheers, Andreas





