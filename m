Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:50612 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751039AbcFIMUA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2016 08:20:00 -0400
From: Andrew W Elble <aweits@rit.edu>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Oleg Drokin <green@linuxhacker.ru>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>
Subject: Re: Files leak from nfsd in 4.7.1-rc1 (and more?)
References: <4EDA6CFD-1FE8-4FCA-ACCF-84250BE342CB@linuxhacker.ru>
	<1465319435.3024.25.camel@poochiereds.net>
	<0F21EDD6-5CBB-4B5B-A1FF-E066011D18D6@linuxhacker.ru>
	<1465329897.3024.38.camel@poochiereds.net>
	<752F7196-1EE7-4FB3-8769-177131C8A793@linuxhacker.ru>
	<1465344205.3024.42.camel@poochiereds.net>
	<AA8AB6FA-E3FF-42B9-A275-0173BD667B0F@linuxhacker.ru>
	<1465383501.27742.19.camel@poochiereds.net>
Date: Thu, 09 Jun 2016 08:13:18 -0400
In-Reply-To: <1465383501.27742.19.camel@poochiereds.net> (Jeff Layton's
	message of "Wed, 08 Jun 2016 06:58:21 -0400")
Message-ID: <m2a8iuy2zl.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> But...suppose we have two racing OPEN calls. They're both in
> nfs4_get_vfs_file. One opens the file and succeeds and the other fails
> and ends up in out_put_access. At that point, you could end up
> clobbering the successful update to st_access_bmap from the other task,
> and we'd end up not putting the file access references in
> release_all_access.


   Pondering further (with an assumption about the workload), isn't this
   path also likely to involve a lease break in progress on that file?

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
