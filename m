Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 072D21D5CFE;
	Thu, 30 Jul 2026 23:36:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.156.1
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785454562; cv=none; b=n40bTFGPD3C0W9tXV11I/Ov6/FmARV8XF83cKxhC7Bz5P1W4P6fyECg5bV97R5PymJqerEaekZ41AABFt/OYg7QsrJCaNpAGOoejNgb+h6WyeVk7BKL/4EV3ZqrP31Y8O3zzytXHtEaF6GG/c4Q5yb9iGMMI+zztmjbVkb6JKZI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785454562; c=relaxed/simple;
	bh=KltlIWHQdy55FF2fcgocO5dc5uXirh7+FQkI4dQ3OHA=;
	h=Message-ID:Subject:From:To:Cc:In-Reply-To:References:Content-Type:
	 Date:MIME-Version; b=F8hoRsNK0o2IgnmhW19QQROUbNA4cEpWfbGYZdi8+fHYN6Xw8vfzZpthJeda325fEq+Cx4yNHIYcC5y4LV8A9kdFd7imLecd7XQ1EmxwD7rep5Gv4mb5IiIl3fmakna+Ikk+ajwOYLWi8dC2J4MtBdhyke3TkXTxKxHIX+78P8Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.ibm.com; spf=pass smtp.mailfrom=linux.ibm.com; dkim=pass (2048-bit key) header.d=ibm.com header.i=@ibm.com header.b=porBPOmO; arc=none smtp.client-ip=148.163.156.1
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.ibm.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ibm.com header.i=@ibm.com header.b="porBPOmO"
Received: from pps.filterd (m0353729.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 66UNHeEq2518103;
	Thu, 30 Jul 2026 23:35:28 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ibm.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=pp1; bh=qP3GW3
	TbOzydv2cSkXUiDsmS7TkqwMXL69Zn2Hpq834=; b=porBPOmOJx4o2a1PILUNvO
	v5Cx/Z5F5zpO2BPZvztZluD+z93NTkxaZcN7XcXhc8jgqjhRyshotIqH+y3ScvZ8
	lol8xR5fPlWx8xNawM6Zwrviwy1ryjLsRsQoXjfEQzMhjM5zcHIXdenVKdqLGlW2
	GzV+PjzEsCf6k/b+LkMhlZs9e7KeoJ3+6HRk9JNdV+8oBq+JAsLNLGph8eSQuDwN
	x2Eux/qX6/N3w/eimwfj1RHhKD1PFnmIf5pXgkFydZ388oCA9PTiiSQGtA996fpM
	7zptBFfcf3akIOrgi4mQD11EmyO5jMlZbvtJV/+T70VdGbKoDzPqjimRTtTxEt9w
	==
Received: from ppma13.dal12v.mail.ibm.com (dd.9e.1632.ip4.static.sl-reverse.com [50.22.158.221])
	by mx0a-001b2d01.pphosted.com (PPS) with ESMTPS id 4fmuyctaf7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 30 Jul 2026 23:35:27 +0000 (GMT)
Received: from pps.filterd (ppma13.dal12v.mail.ibm.com [127.0.0.1])
	by ppma13.dal12v.mail.ibm.com (8.18.1.7/8.18.1.7) with ESMTP id 66UNQKBa009388;
	Thu, 30 Jul 2026 23:35:26 GMT
Received: from smtprelay05.dal12v.mail.ibm.com ([172.16.1.7])
	by ppma13.dal12v.mail.ibm.com (PPS) with ESMTPS id 4fn9pgnf4m-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 30 Jul 2026 23:35:26 +0000 (GMT)
Received: from smtpav05.dal12v.mail.ibm.com (smtpav05.dal12v.mail.ibm.com [10.241.53.104])
	by smtprelay05.dal12v.mail.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id 66UNZQmF17433292
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 30 Jul 2026 23:35:26 GMT
Received: from smtpav05.dal12v.mail.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 53F3558056;
	Thu, 30 Jul 2026 23:35:26 +0000 (GMT)
Received: from smtpav05.dal12v.mail.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5897C58052;
	Thu, 30 Jul 2026 23:35:25 +0000 (GMT)
Received: from li-43857255-d5e6-4659-90f1-fc5cee4750ad.ibm.com (unknown [9.61.66.203])
	by smtpav05.dal12v.mail.ibm.com (Postfix) with ESMTP;
	Thu, 30 Jul 2026 23:35:25 +0000 (GMT)
Message-ID: <4bdf58bd593d9a54aa20760fd49aaa1df57ef216.camel@linux.ibm.com>
Subject: Re: [PATCH v3 1/2] vfs: Allow filesystems with foreign owner IDs
 to override UID checks
From: Mimi Zohar <zohar@linux.ibm.com>
To: David Howells <dhowells@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
        Christian Brauner <christian@brauner.io>
Cc: Marc Dionne <marc.dionne@auristor.com>,
        Jeffrey Altman	
 <jaltman@auristor.com>,
        Steve French <sfrench@samba.org>, linux-afs@lists.infradead.org,
        openafs-devel@openafs.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Etienne
 Champetier	 <champetier.etienne@gmail.com>,
        Chet Ramey
 <chet.ramey@case.edu>,
        Cheyenne Wills <cwills@sinenomine.net>,
        Christian
 Brauner <brauner@kernel.org>,
        linux-integrity@vger.kernel.org
In-Reply-To: <20260728141344.1811120-2-dhowells@redhat.com>
References: <20260728141344.1811120-1-dhowells@redhat.com>
	 <20260728141344.1811120-2-dhowells@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 30 Jul 2026 19:35:24 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Evolution 3.58.3 (3.58.3-1.fc43) 
X-TM-AS-GCONF: 00
X-Proofpoint-Reinject: loops=2 maxloops=12
X-Proofpoint-ORIG-GUID: lcGThnKMZT8UYbD7373ywCh4ibsccC3z
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwNzMwMDE2NiBTYWx0ZWRfX+x2/6K46F/EV
 gjpwLQaAo6chWT7bKEU+8evGFJpAo6zrehwYKSASkJUIQf2eylmEzxpkuTunfJxxs5hUTFgfsk0
 swsKXkMU8snbhqqmjy2Sf6WuQews6yXQLa6+A/+2UYkL/b6zOMW1GxtzcjNGrgAgMj7XOyqaQYi
 l1UdbD79E5Sj+Y0w2kw//4fqiNOVv/4UIsl5CvTE8J7aj6alYyFwIKFETILVQzx/YSWMyDcgqY5
 +U5mspmVTU46lsirJYw0Oiip3hyygPPWjOsyysepyWW3ypfjo+z/cO75vamUcUteHTVxUMIuqO/
 OBN2cLDRiCGem+abARewNbR12LJ24387wXbkMKbO21qEMsFZMfqloIGIbezWGztljqyGHanmpBm
 ZxXT+Kr4oPy7fx0xIjBwL3r6QI4DDDLq/NnIooQf8LbxRdaWlNM/iJRY3ZUNBALSTRS6OE8ntVy
 wYjqqFE1wNmdXg1ch7A==
X-Proofpoint-Spam-Info: AW1haW4tMjYwNzMwMDE2NiBTYWx0ZWRfXxx/LofNCpxFd
 Qyt6vsbR7yXIXEWdRbQIW06/QbzZZNUCdAs9sx6zZrU8FgGaIAwrD+zh3WQ3XEf2fY9qivXJQnD
 WyK6UGHxX/413KHJOpXW5V3I7EH6f5A=
X-Authority-Analysis: v=2.4 cv=AZeB2XXG c=1 sm=1 tr=0 ts=6a6bdfc0 cx=c_pps
 a=AfN7/Ok6k8XGzOShvHwTGQ==:117 a=AfN7/Ok6k8XGzOShvHwTGQ==:17
 a=IkcTkHD0fZMA:10 a=RAioF0-LDSMA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=RnoormkPH1_aCDwRdu11:22 a=uAbxVGIbfxUO_5tXvNgY:22 a=hS9qXHsXj7WBoA4L2p0A:9
 a=QEXdDO2ut3YA:10
X-Proofpoint-GUID: w0I0ySVcKgzse6q7Ns7VItQIsoQobE1S
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1143,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-07-30_07,2026-07-30_01,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 spamscore=0 priorityscore=1501 phishscore=0 adultscore=0 impostorscore=0
 clxscore=1011 malwarescore=0 suspectscore=0 lowpriorityscore=0 bulkscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2607300166

Hi David,

On Tue, 2026-07-28 at 15:13 +0100, David Howells wrote:
>=20
>  (*) IMA policy ops.
>=20
>      Unchanged for now.  I'm not sure what the best way to deal with this
>      is - if, indeed, it needs any changes.

IMA policy rules may be written in terms of the uid, euid and fowner.  Any
changes, if necessary, would need to be made to ima_match_rules().

Mimi
