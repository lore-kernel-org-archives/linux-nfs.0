Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=epfl.ch header.i=@epfl.ch header.b="1FD1CUdX"
Received: from smtp0.epfl.ch (smtp0.epfl.ch [IPv6:2001:620:618:1e0:1:80b2:e058:1])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id BEB5085
	for <linux-nfs@vger.kernel.org>; Mon, 27 Nov 2023 09:23:35 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=epfl.ch;
      s=epfl; t=1701105812;
      h=From:To:CC:Subject:Date:Message-ID:Content-Type:Content-Transfer-Encoding:MIME-Version;
      bh=N8iQsjovET5/ng2xE2gL+ZpwgBdfDCb3pC++/JBMfik=;
      b=1FD1CUdXUrWrxsKPqpBrUyq1po1T7RaMimJvRtDYyO0NCBnMFazjtUMdUnLAy8yXB
        mSo1dDI7ctboHcmTwXGXH1CWL3ln9K+vxTdkhnNwiZ94S5AkK6mVbcxZfk/kn9f6e
        DUyeJpqSMQ9QsrFBwWbQEVPZ6GaEz3alNRR0eTYic=
Received: (qmail 15758 invoked by uid 107); 27 Nov 2023 17:23:32 -0000
Received: from ax-snat-224-179.epfl.ch (HELO ewa08.intranet.epfl.ch) (192.168.224.179) (TLS, ECDHE-RSA-AES256-GCM-SHA384 (P-256 curve) cipher)
  by mail.epfl.ch (AngelmatoPhylax SMTP proxy) with ESMTPS; Mon, 27 Nov 2023 18:23:32 +0100
X-EPFL-Auth: JfOClGE7A8BqlrB59yN2XhdSolh5SNC+7+ugPh94cRJNiwGt678=
Received: from ewa07.intranet.epfl.ch (128.178.224.178) by
 ewa08.intranet.epfl.ch (128.178.224.179) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.1.2507.34; Mon, 27 Nov 2023 18:23:32 +0100
Received: from ewa07.intranet.epfl.ch ([fe80::f470:9b62:7382:7f3a]) by
 ewa07.intranet.epfl.ch ([fe80::f470:9b62:7382:7f3a%4]) with mapi id
 15.01.2507.034; Mon, 27 Nov 2023 18:23:32 +0100
From: Tao Lyu <tao.lyu@epfl.ch>
To: "hch@infradead.org" <hch@infradead.org>, Trond Myklebust
	<trondmy@hammerspace.com>, "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Question about O_APPEND | O_DIRECT
Thread-Topic: Question about O_APPEND | O_DIRECT
Thread-Index: AQHaHjflhODFfyeMXUSkxSGiPt/2HLCLuRkAgAKTcNCAAAYXgIAACNMAgAADIoCAABEw1g==
Date: Mon, 27 Nov 2023 17:23:32 +0000
Message-ID: <dec2fddf11b94acd8c82462b87f2c8e8@epfl.ch>
References: <c609e5f9df75438dbfe3810859935d58@epfl.ch>
 <2d948b43fa625952e50589e4bedf9551df7ee112.camel@hammerspace.com>
 <7d2d17e4d3904d29b75fadcfd916b2a3@epfl.ch> <ZWTFn0/FtJ5WuQGc@infradead.org>
 <20107e878f185628a8d498ebb046e55618abfd4f.camel@hammerspace.com>,<ZWTPp8R6ywfT9hRS@infradead.org>
In-Reply-To: <ZWTPp8R6ywfT9hRS@infradead.org>
Accept-Language: en-US, fr-CH
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

Hi Trond, Christoph, and Chuck,

I understand it.
Thanks a lot for your explanation.

Best,
Tao=
