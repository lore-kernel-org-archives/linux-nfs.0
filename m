Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:33015 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753664AbbGaTrR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Jul 2015 15:47:17 -0400
Received: by qged69 with SMTP id d69so53130406qge.0
        for <linux-nfs@vger.kernel.org>; Fri, 31 Jul 2015 12:47:16 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2102\))
Subject: Re: [PATCH] nfsidmap: Enumerate kernel cache of ID mapping results
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <6788.1438371183@warthog.procyon.org.uk>
Date: Fri, 31 Jul 2015 15:47:10 -0400
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <BA520196-CB02-4C4F-A779-FA83B1C538FC@gmail.com>
References: <20150731175414.8708.69775.stgit@seurat.1015granger.net> <6788.1438371183@warthog.procyon.org.uk>
To: David Howells <dhowells@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 31, 2015, at 3:33 PM, David Howells <dhowells@redhat.com> wrote:
> 
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> +	if ((fp = fopen(PROCKEYS, "r")) == NULL) {
>> +		xlog_err("fopen(%s) failed: %m", PROCKEYS);
>> +		return 1;
>> +	}
>> +
>> +	rc = 1;
>> +	while(fgets(buf, BUFSIZ, fp) != NULL) {
>> +		unsigned int id;
>> +
>> +		if (strstr(buf, "keyring") == NULL)
>> +			continue;
>> +		if (strstr(buf, keyring) == NULL)
>> +			continue;
>> +		if (sscanf(buf, "%x %*s", &id) != 1)
>> +			continue;
>> +
>> +		list_keys(keyring, (key_serial_t)id);
>> +		rc = 0;
>> +		break;
>> +	}
>> +
> 
> Did you want find_key_by_type_and_desc() in libkeyutils?

Yes, but find_key_by_type_and_desc() does not appear in older
versions of /usr/include/keyutils.h.

Well, I think this logic can be factored out (it is also used
in keyring_clear) and used if find_key_by_type_and_desc()
does not exist.


--
Chuck Lever
chucklever@gmail.com



